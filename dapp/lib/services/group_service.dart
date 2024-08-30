import 'package:dapp/enum/escrow_factory_functions.dart';
import 'package:dapp/enum/escrow_functions.dart';
import 'package:dapp/model/group_profile_model.dart';
import 'package:dapp/services/ethereum_service.dart';
import 'package:dapp/utils/utils.dart';
import 'package:web3dart/web3dart.dart';

class GroupService {
  final EthereumService _ethereumService;

  GroupService(this._ethereumService);

  EthereumAddress get userAddress => _ethereumService.userAddress;
  EthereumAddress get escrowAddress => _ethereumService.escrowAddress;

  Future<List<GroupProfile>> fetchGroupProfiles() async {
    List<GroupProfile> groups = [];
    String myEscrowAddress = _ethereumService.escrowContract.address.toString();
    List<String> myGroupNames = await fetchGroupNames(myEscrowAddress);

    groups.addAll(await createGroupProfile(myEscrowAddress, myGroupNames));

    List<String> escrowMembershipAddresses =
        await fetchEscrowMembershipAddresses();

    for (String escrowAddress in escrowMembershipAddresses) {
      List<String> escrowMemberGroupNames =
          await fetchGroupNames(escrowAddress);
      groups.addAll(
          await createGroupProfile(escrowAddress, escrowMemberGroupNames));
    }

    return groups;
  }

  Future<List<GroupProfile>> createGroupProfile(
      String contractAddress, List<String> groupNames) async {
    List<GroupProfile> groupProfiles = [];
    for (String groupName in groupNames) {
      final GroupProfile groupProfile =
          await fetchGroupProfile(contractAddress, groupName);

      groupProfiles.add(groupProfile);
    }
    return groupProfiles;
  }

  Future<GroupProfile> fetchGroupProfile(
      String contractAddress, String groupName) async {
    DeployedContract contract =
        await _ethereumService.loadEscrowContract(contractAddress);

    final group = await _ethereumService.query(contract,
        EscrowFunctions.getGroupDetails.functionName, [groupName], true);
    String groupSize = group[0].toString();
    String groupDeposit = group[1].toString();
    String groupID = Utils.generateUniqueID(groupName, contractAddress);
    List<String> memberAddresses = (group[2] as List<dynamic>)
        .map((address) => address.toString())
        .toList();

    return GroupProfile(
        groupID: groupID,
        groupName: groupName,
        contractAddress: contractAddress,
        deposit: groupDeposit,
        groupImagePath: 'assets/default_avatar.jpg',
        membersCount: groupSize,
        memberAddresses: memberAddresses);
  }

  Future<List<String>> fetchGroupNames(String contractAddress) async {
    final DeployedContract deployedContract =
        await _ethereumService.loadEscrowContract(contractAddress);
    final List<dynamic> groupNamesResponse = await _ethereumService.query(
        deployedContract,
        EscrowFunctions.getAllMemberGroupNames.functionName,
        [],
        true);

    return (groupNamesResponse[0] as List<dynamic>)
        .map((name) => name as String)
        .toList();
  }

  Future<List<String>> fetchEscrowMembershipAddresses() async {
    final List<dynamic> response = await _ethereumService.query(
        _ethereumService.escrowFactoryContract,
        EscrowFactoryFunctions.getUserEscrowMemberships.functionName,
        [],
        true);

    List<String> userEscrowMemberships = (response[0] as List<dynamic>)
        .map((address) => address.toString())
        .toList();
    return userEscrowMemberships;
  }

  void addNewGroup(List<dynamic> args) {
    _ethereumService.callFunction(
      _ethereumService.escrowAddress.toString(),
      EscrowFunctions.createGroup.functionName,
      args,
    );
  }

  void disbandGroup(String groupName, String contractAddress) {
    List<dynamic> args = [groupName];
    _ethereumService.callFunction(
        contractAddress, EscrowFunctions.disbandGroup.functionName, args);
  }
}
