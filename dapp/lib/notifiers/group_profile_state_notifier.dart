import 'package:dapp/enum/escrow_functions.dart';
import 'package:dapp/model/group_profile_model.dart';
import 'package:dapp/services/ethereum_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web3dart/web3dart.dart';

class GroupProfileNotifier extends StateNotifier<Map<String, GroupProfile>> {
  final EthereumService ethereumService;

  GroupProfileNotifier(this.ethereumService) : super({}) {
    _listenToGroupEvents();
  }

  Future<List<GroupProfile>> fetchGroupProfilesFromBlockchain() async {
    DeployedContract escrowContract = ethereumService.escrowContract;
    List<GroupProfile> groups = [];

    final response = await ethereumService.query(escrowContract,
        EscrowFunctions.getAllGroupNames.functionName, [], false);
    List<dynamic> groupNames = response[0];

    for (var groupName in groupNames) {
      final group =
          await fetchGroupProfileFromBlockChain(escrowContract, groupName);
      String groupSize = group[0].toString();
      String groupDeposit = group[1].toString();

      groups.add(GroupProfile(
        groupName: groupName,
        deposit: groupDeposit,
        groupImagePath: 'assets/default_avatar.jpg',
        membersCount: groupSize,
      ));
    }
    return groups;
  }

  Future<List<dynamic>> fetchGroupProfileFromBlockChain(
      DeployedContract escrowContract, String groupName) async {
    return ethereumService.query(
        escrowContract,
        EscrowFunctions.getGroupSizeAndMemberDeposit.functionName,
        [groupName],
        true);
  }

  Future<void> loadGroupProfiles() async {
    List<GroupProfile> groups = await fetchGroupProfilesFromBlockchain();
    state = {for (var group in groups) group.groupName: group};
  }

  void updateGroup(GroupProfile group) {
    state = {
      ...state,
      group.groupName: group,
    };
  }

  bool get isEmpty => state.isEmpty;

  _listenToGroupEvents() {
    ethereumService.listenToGroupCreatedEvents(_handleGroupCreated);
  }

  void _handleGroupCreated(String groupName, EthereumAddress owner) async {
    if (owner == ethereumService.userAddress) {
      final group = await fetchGroupProfileFromBlockChain(
          ethereumService.escrowContract, groupName);
      String groupSize = group[0].toString();
      String groupDeposit = group[1].toString();

      updateGroup(GroupProfile(
          groupName: groupName,
          deposit: groupDeposit,
          groupImagePath: 'assets/default_avatar.jpg',
          membersCount: groupSize));
    }
  }
}
