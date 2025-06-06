import 'package:dapp/custom_exception/custom_exception.dart';
import 'package:dapp/enum/erc20_usdc_functions.dart';
import 'package:dapp/enum/escrow_factory_functions.dart';
import 'package:dapp/enum/escrow_functions.dart';
import 'package:dapp/model/group_profile_model.dart';
import 'package:dapp/services/ethereum_service.dart';
import 'package:dapp/utils/decimal_bigint_converter.dart';
import 'package:dapp/utils/utils.dart';
import 'package:decimal/decimal.dart';
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
    BigInt groupDeposit = group[1] as BigInt;
    String groupDepositDecimal =
        DecimalBigIntConverter.bigIntToDecimal(groupDeposit).toStringAsFixed(2);
    String groupID = Utils.generateUniqueID(groupName, contractAddress);
    List<String> memberAddresses = (group[2] as List<dynamic>)
        .map((address) => address.toString())
        .toList();

    return GroupProfile(
        groupID: groupID,
        groupName: groupName,
        contractAddress: contractAddress,
        deposit: groupDepositDecimal,
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

  Future<String> fetchGroupMemberBalance(
      String groupName, String contractAddress) async {
    final DeployedContract deployedContract =
        await _ethereumService.loadEscrowContract(contractAddress);
    final List<dynamic> groupMemberBalanceResponse =
        await _ethereumService.query(
            deployedContract,
            EscrowFunctions.getGroupMemberBalance.functionName,
            [groupName],
            true);

    BigInt groupDeposit = groupMemberBalanceResponse[0] as BigInt;
    String groupDepositDecimal =
        DecimalBigIntConverter.bigIntToDecimal(groupDeposit).toStringAsFixed(2);
    return groupDepositDecimal;
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

  Future<void> addNewGroup(List<dynamic> args) async {
    try {
      await _ethereumService.callFunction(
          _ethereumService.escrowAddress.toString(),
          EscrowFunctions.createGroup.functionName,
          args);
    } on RpcException {
      rethrow;
    } on GeneralException {
      rethrow;
    } catch (e) {
      throw GeneralException('Unknown error in GroupService: $e');
    }
  }

  Future<void> disbandGroup(String groupName, String contractAddress) async {
    List<dynamic> args = [groupName];

    try {
      await _ethereumService.callFunction(
          contractAddress, EscrowFunctions.disbandGroup.functionName, args);
    } on RpcException {
      rethrow;
    } on GeneralException {
      rethrow;
    } catch (e) {
      throw GeneralException('Unknown error in GroupService: $e');
    }
  }

  Future<void> depositToGroup(
      String groupName, String contractAddress, String amount) async {
    BigInt depositAmount =
        DecimalBigIntConverter.decimalToBigInt(Decimal.parse(amount));
    List<dynamic> args = [groupName, depositAmount];

    bool isAllowanceSuffice = await isMemberTokenAllowanceSufficient(amount);
    try {
      if (!isAllowanceSuffice) {
        await approveUsdcAllowance(amount);
      }

      await Future.delayed(const Duration(seconds: 1));

      await _ethereumService.callFunction(
          contractAddress, EscrowFunctions.depositToGroup.functionName, args);
    } on RpcException {
      rethrow;
    } on GeneralException {
      rethrow;
    } catch (e) {
      throw GeneralException('Unknown error in GroupService: $e');
    }
  }

  Future<void> withdrawFromGroup(
      String groupName, String contractAddress, String amount) async {
    BigInt depositAmount =
        DecimalBigIntConverter.decimalToBigInt(Decimal.parse(amount));
    List<dynamic> args = [groupName, depositAmount];

    try {
      await _ethereumService.callFunction(contractAddress,
          EscrowFunctions.withdrawFromGroup.functionName, args);
    } on RpcException {
      rethrow;
    } on GeneralException {
      rethrow;
    } catch (e) {
      throw GeneralException('Unknown error in GroupService: $e');
    }
  }

  Future<void> approveUsdcAllowance(String amount) async {
    BigInt depositUsdcUnitAmount =
        DecimalBigIntConverter.decimalToUsdcUnit(Decimal.parse(amount));
    EthereumAddress spender = _ethereumService.escrowAddress;
    List<dynamic> args = [spender, depositUsdcUnitAmount];

    return await _ethereumService.callFunction(
        _ethereumService.usdcContractAddress,
        Erc20UsdcFunctions.approve.functionName,
        args);
  }

  Future<bool> isMemberTokenAllowanceSufficient(String amount) async {
    BigInt depositUsdcUnitAmount =
        DecimalBigIntConverter.decimalToUsdcUnit(Decimal.parse(amount));
    EthereumAddress owner = _ethereumService.userAddress;
    EthereumAddress spender = _ethereumService.escrowAddress;
    List<dynamic> args = [owner, spender];

    final List<dynamic> allowanceResponse = await _ethereumService.query(
        _ethereumService.usdcContract,
        Erc20UsdcFunctions.allowance.functionName,
        args,
        false);
    BigInt allowanceAmount = allowanceResponse[0] as BigInt;
    return allowanceAmount >= depositUsdcUnitAmount ? true : false;
  }
}
