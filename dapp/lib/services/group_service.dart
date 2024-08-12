import 'package:dapp/enum/escrow_functions.dart';
import 'package:dapp/model/group_profile_model.dart';
import 'package:dapp/services/ethereum_service.dart';
import 'package:web3dart/web3dart.dart';

class GroupService {
  final EthereumService _ethereumService;

  GroupService(this._ethereumService);

  Future<List<GroupProfile>> fetchGroupProfilesFromBlockchain() async {
    List<GroupProfile> groups = [];

    final response = await _ethereumService.query(
        _ethereumService.escrowContract,
        EscrowFunctions.getAllGroupNames.functionName,
        [],
        false);
    List<dynamic> groupNames = response[0];

    for (var groupName in groupNames) {
      final group = await fetchGroupProfileFromBlockChain(groupName);
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
      String groupName) async {
    return _ethereumService.query(
        _ethereumService.escrowContract,
        EscrowFunctions.getGroupSizeAndMemberDeposit.functionName,
        [groupName],
        true);
  }

  void addNewGroup(List<dynamic> args) {
    _ethereumService.callFunction(
      _ethereumService.escrowContract,
      EscrowFunctions.createGroup.functionName,
      args,
    );
  }

  listenToGroupCreatedEvents(Function(String, EthereumAddress) handler) {
    _ethereumService.listenToGroupCreatedEvents(handler);
  }

  EthereumAddress get userAddress => _ethereumService.userAddress;
}
