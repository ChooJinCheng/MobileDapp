import 'package:dapp/custom_exception/custom_exception.dart';
import 'package:dapp/event_bus/event_bus_singleton.dart';
import 'package:dapp/model/group_profile_model.dart';
import 'package:dapp/services/event_listener_manager.dart';
import 'package:dapp/services/group_service.dart';
import 'package:dapp/utils/utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/web3dart.dart';

class GroupProfileNotifier extends StateNotifier<Map<String, GroupProfile>> {
  final GroupService groupService;
  final EventListenerManager eventListenerManager;

  GroupProfileNotifier(this.groupService, this.eventListenerManager)
      : super({}) {
    _listenToGroupEvents();
  }

  bool get isEmpty => state.isEmpty;

  Future<void> loadGroupProfiles() async {
    try {
      List<GroupProfile> groups = await groupService.fetchGroupProfiles();
      state = {for (var group in groups) group.groupID: group};
    } catch (e) {
      print('Error: $e');
    }
  }

  void addGroup(GroupProfile group) {
    state = {
      ...state,
      group.groupID: group,
    };
  }

  void removeGroup(String groupID) {
    Map<String, GroupProfile> newState = Map<String, GroupProfile>.from(state);
    newState.remove(groupID);
    state = newState;
  }

  Future<void> depositToGroup(
      String groupName, String contractAddress, String amount) async {
    try {
      await groupService.depositToGroup(groupName, contractAddress, amount);
      String groupID = Utils.generateUniqueID(groupName, contractAddress);
      await _updateGroupMemberBalance(groupID);
    } on RpcException {
      rethrow;
    } on GeneralException {
      rethrow;
    } catch (e) {
      throw GeneralException('Unknown error in GroupProfileStateNotifier: $e');
    }
  }

  Future<void> withdrawFromGroup(
      String groupName, String contractAddress, String amount) async {
    try {
      await groupService.withdrawFromGroup(groupName, contractAddress, amount);
      String groupID = Utils.generateUniqueID(groupName, contractAddress);
      await _updateGroupMemberBalance(groupID);
    } on RpcException {
      rethrow;
    } on GeneralException {
      rethrow;
    } catch (e) {
      throw GeneralException('Unknown error in GroupProfileStateNotifier: $e');
    }
  }

  _listenToGroupEvents() async {
    try {
      List<String> escrowAddresses =
          await groupService.fetchEscrowMembershipAddresses();
      escrowAddresses.add(groupService.escrowAddress.toString());

      for (String address in escrowAddresses) {
        eventListenerManager.listenToGroupCreatedEvents(
            address, _handleGroupCreated);
        eventListenerManager.listenToGroupDisbandedEvents(
            address, _handleGroupDisbanded);
      }
      eventListenerManager
          .listenToEscrowRegisteredEvents(_handleEscrowRegistered);
      eventListenerManager
          .listenToEscrowDeregisteredEvents(_handleEscrowDeregistered);

      AppEventBus.instance.on<TransactionExecutedEvent>().listen((event) async {
        String groupID = event.groupID;
        await _updateGroupMemberBalance(groupID);
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _updateGroupMemberBalance(String groupID) async {
    try {
      if (state.containsKey(groupID)) {
        GroupProfile? group = state[groupID];
        if (group != null) {
          String groupDeposit = await groupService.fetchGroupMemberBalance(
              group.groupName, group.contractAddress);
          group.deposit = groupDeposit;

          Map<String, GroupProfile> newState =
              Map<String, GroupProfile>.from(state);
          newState[groupID] = group;
          state = newState;
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _handleGroupCreated(String groupName, List<EthereumAddress> members,
      String memberContractAddress) async {
    try {
      for (EthereumAddress member in members) {
        if (member == groupService.userAddress) {
          await _fetchAndUpdateGroup(groupName, memberContractAddress);
          break;
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _handleGroupDisbanded(String groupName, List<EthereumAddress> members,
      String memberContractAddress) async {
    try {
      for (EthereumAddress member in members) {
        if (member == groupService.userAddress) {
          String groupID =
              Utils.generateUniqueID(groupName, memberContractAddress);
          removeGroup(groupID);
          AppEventBus.instance.fire(GroupDisbandedEvent(groupID));
          break;
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _handleEscrowRegistered(
      String groupName,
      EthereumAddress memberContractAddress,
      EthereumAddress memberAddress) async {
    try {
      if (memberAddress == groupService.userAddress) {
        String memberContractAddressStr = memberContractAddress.toString();
        eventListenerManager.listenToGroupCreatedEvents(
            memberContractAddressStr, _handleGroupCreated);
        eventListenerManager.listenToGroupDisbandedEvents(
            memberContractAddressStr, _handleGroupDisbanded);
        await _fetchAndUpdateGroup(groupName, memberContractAddressStr);
        AppEventBus.instance
            .fire(EscrowRegisteredEvent(memberContractAddressStr));
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _handleEscrowDeregistered(
      String groupName,
      EthereumAddress memberContractAddress,
      EthereumAddress memberAddress) async {
    try {
      if (memberAddress == groupService.userAddress) {
        eventListenerManager
            .stopListeningForContract(memberContractAddress.toString());
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _fetchAndUpdateGroup(
      String groupName, String memberContractAddress) async {
    final GroupProfile groupProfile =
        await groupService.fetchGroupProfile(memberContractAddress, groupName);
    addGroup(groupProfile);
  }
}
