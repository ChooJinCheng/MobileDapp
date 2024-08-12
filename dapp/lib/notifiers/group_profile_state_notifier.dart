import 'package:dapp/model/group_profile_model.dart';
import 'package:dapp/services/group_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web3dart/web3dart.dart';

class GroupProfileNotifier extends StateNotifier<Map<String, GroupProfile>> {
  final GroupService groupService;

  GroupProfileNotifier(this.groupService) : super({}) {
    _listenToGroupEvents();
  }

  Future<void> loadGroupProfiles() async {
    List<GroupProfile> groups =
        await groupService.fetchGroupProfilesFromBlockchain();
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
    groupService.listenToGroupCreatedEvents(_handleGroupCreated);
  }

  void _handleGroupCreated(String groupName, EthereumAddress owner) async {
    if (owner == groupService.userAddress) {
      final group =
          await groupService.fetchGroupProfileFromBlockChain(groupName);
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
