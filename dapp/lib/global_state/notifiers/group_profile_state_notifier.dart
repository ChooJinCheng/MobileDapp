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
    List<GroupProfile> groups = await groupService.fetchGroupProfiles();
    state = {for (var group in groups) group.groupID: group};
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

  _listenToGroupEvents() async {
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
    });
  }

  void _handleGroupCreated(String groupName, List<EthereumAddress> members,
      String memberContractAddress) async {
    for (EthereumAddress member in members) {
      if (member == groupService.userAddress) {
        await _fetchAndUpdateGroup(groupName, memberContractAddress);
        break;
      }
    }
  }

  void _handleGroupDisbanded(String groupName, List<EthereumAddress> members,
      String memberContractAddress) async {
    for (EthereumAddress member in members) {
      if (member == groupService.userAddress) {
        String groupID =
            Utils.generateUniqueID(groupName, memberContractAddress);
        removeGroup(groupID);
        AppEventBus.instance.fire(GroupDisbandedEvent(groupID));
        break;
      }
    }
  }

  void _handleEscrowRegistered(
      String groupName,
      EthereumAddress memberContractAddress,
      EthereumAddress memberAddress) async {
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
  }

  void _handleEscrowDeregistered(
      String groupName,
      EthereumAddress memberContractAddress,
      EthereumAddress memberAddress) async {
    if (memberAddress == groupService.userAddress) {
      eventListenerManager
          .stopListeningForContract(memberContractAddress.toString());
    }
  }

  Future<void> _fetchAndUpdateGroup(
      String groupName, String memberContractAddress) async {
    final GroupProfile groupProfile =
        await groupService.fetchGroupProfile(memberContractAddress, groupName);
    addGroup(groupProfile);
  }
}
