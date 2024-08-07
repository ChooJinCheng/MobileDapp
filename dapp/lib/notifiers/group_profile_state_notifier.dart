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
    print('Response of getAllGroupNames Funct: $response');
    List<dynamic> groupNames = response[0];
    int groupCount = 1;
    for (var groupName in groupNames) {
      final group =
          await fetchGroupProfileFromBlockChain(escrowContract, groupName);
      groups.add(GroupProfile(
        groupID: groupCount,
        groupName: groupName,
        deposit: group[1].toString(),
        groupImagePath: 'assets/default_avatar.jpg',
        membersCount: group[0].toString(),
      ));
      groupCount++;
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

  void _handleGroupCreated(String groupName, EthereumAddress owner) {}
}
