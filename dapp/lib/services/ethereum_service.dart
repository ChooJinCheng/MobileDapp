import 'dart:async';

import 'package:dapp/enum/escrow_events.dart';
import 'package:dapp/enum/transaction_status_enum.dart';
import 'package:dapp/model/user_transaction_model.dart';
import 'package:dapp/utils/utils.dart';
import 'package:http/http.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/json_rpc.dart';
import 'package:web3dart/web3dart.dart';
import 'package:dapp/services/ethereum_abi_loader.dart';
import 'package:dapp/enum/escrow_factory_functions.dart';

class EthereumService {
  static final EthereumService _instance = EthereumService._internal();
  static const int _chainID = 1337;
  late String _rpcUrl;
  late String _privateKey;
  late String factoryContractAddress;
  late DeployedContract escrowContract;
  late DeployedContract escrowFactoryContract;
  late Web3Client _client;
  late EthPrivateKey _credentials;

  EthereumService._internal();

  factory EthereumService(
      {required String rpcUrl,
      required String privateKey,
      required String factoryContractAddress}) {
    _instance._rpcUrl = rpcUrl;
    _instance._privateKey = privateKey;
    _instance.factoryContractAddress = factoryContractAddress;
    _instance._initialize();
    return _instance;
  }

  void _initialize() async {
    _client = Web3Client(_rpcUrl, Client());
    _credentials = EthPrivateKey.fromHex(_privateKey);

    escrowFactoryContract = await _instance.loadFactoryContract();
    final response = await _instance.query(escrowFactoryContract,
        EscrowFactoryFunctions.getEscrow.functionName, [], true);
    String address = response[0].toString();

    _initializeContacts(_credentials.address.toString());

    if (address != '0x0000000000000000000000000000000000000000') {
      escrowContract = await _instance.loadEscrowContract(address);
      print('Escrow Contract is already deployed at: $address');
    } else {
      await deployEscrowContract(escrowFactoryContract);
      final address = await query(escrowFactoryContract,
          EscrowFactoryFunctions.getEscrow.functionName, [], true);
      escrowContract =
          await _instance.loadEscrowContract(address[0].toString());
      print('Newly deployed escrow at: $address');
    }
  }

  void _initializeContacts(String userAddress) async {
    //TODO:Temporary placed here, need to move else where more appropriate
    await Utils.initializeContact(userAddress);
  }

  EthereumAddress get userAddress => _credentials.address;
  EthereumAddress get escrowAddress => escrowContract.address;

  deployEscrowContract(DeployedContract factoryContract) async {
    return await callFunction(factoryContractAddress,
        EscrowFactoryFunctions.deployEscrow.functionName, []);
  }

  Future<DeployedContract> loadContract(
      String abiPath, String contractAddress) async {
    final abiString = await loadAbi(abiPath);
    final contract = DeployedContract(
      ContractAbi.fromJson(abiString, 'MyContract'),
      EthereumAddress.fromHex(contractAddress),
    );
    return contract;
  }

  Future<DeployedContract> loadEscrowContract(String contractAddress) async {
    final abiString =
        await loadAbi('lib/services/ethereum_contract_json/escrow_abi.json');
    final contract = DeployedContract(
      ContractAbi.fromJson(abiString, 'EscrowContract'),
      EthereumAddress.fromHex(contractAddress),
    );
    return contract;
  }

  Future<DeployedContract> loadFactoryContract() async {
    final abiString = await loadAbi(
        'lib/services/ethereum_contract_json/escrow_factory_abi.json');
    final contract = DeployedContract(
      ContractAbi.fromJson(abiString, 'EscrowFactoryContract'),
      EthereumAddress.fromHex(factoryContractAddress),
    );
    return contract;
  }

  callFunction(
      String contractAddress, String functionName, List<dynamic> args) async {
    DeployedContract deployedContract;
    if (functionName == EscrowFactoryFunctions.deployEscrow.functionName) {
      deployedContract = await loadFactoryContract();
    } else {
      deployedContract = await loadEscrowContract(contractAddress);
    }

    final function = deployedContract.function(functionName);
    try {
      final result = await _client.sendTransaction(
        _credentials,
        Transaction.callContract(
          contract: deployedContract,
          function: function,
          parameters: args,
          maxGas: 6721975,
        ),
        chainId: _chainID,
      );

      TransactionReceipt? receipt;
      while (receipt == null) {
        receipt = await _client.getTransactionReceipt(result);
        if (receipt == null) {
          await Future.delayed(const Duration(seconds: 1));
        }
      }

      /* print('Txn Receipt: $receipt');
      print('Txn Receipt contract addr: ${receipt.contractAddress}');
      print('Txn Receipt logs: ${receipt.logs}');
 */
      return result;
    } catch (e) {
      //TODO: Return the error message back to screen
      if (e is RPCError) {
        String errorMessage = e.message;
        print(errorMessage);
      }
      print('Error in ethService: $e');
    }
  }

  Future<List<dynamic>> query(DeployedContract contract, String functionName,
      List<dynamic> args, bool sendUserAddress) async {
    if (sendUserAddress) {
      args.add(_credentials.address);
    }
    final ethFunction = contract.function(functionName);
    final result = await _client.call(
      contract: contract,
      function: ethFunction,
      params: args,
    );
    return result;
  }

  Future<List<List<dynamic>>> queryEventLogs(
      String contractAddress, String eventName, List<dynamic> args) async {
    DeployedContract deployedContract =
        await loadEscrowContract(contractAddress);
    ContractEvent eventInitiated = deployedContract.event(eventName);

    List<List<String?>> topicsList = [
      [
        bytesToHex(eventInitiated.signature,
            padToEvenLength: true, include0x: true)
      ]
    ];
    for (var param in args) {
      if (param != null) {
        topicsList.add([_formatTopic(param)]);
      }
    }

    FilterOptions filterInitiated = FilterOptions(
      fromBlock: const BlockNum.genesis(),
      toBlock: const BlockNum.current(),
      address: deployedContract.address,
      topics: topicsList,
    );

    final logsInitiated = await _client.getLogs(filterInitiated);
    final decodedLog = logsInitiated.map((log) {
      final decoded = eventInitiated.decodeResults(log.topics!, log.data!);
      return decoded;
    }).toList();

    return decodedLog;
  }

  String _formatTopic(dynamic value) {
    if (value is EthereumAddress) {
      return bytesToHex(value.addressBytes,
          padToEvenLength: true, include0x: true, forcePadLength: 64);
    } else if (value is BigInt) {
      return bytesToHex(intToBytes(value),
          padToEvenLength: true, include0x: true, forcePadLength: 64);
    } else if (value is int) {
      return bytesToHex(intToBytes(BigInt.from(value)),
          padToEvenLength: true, include0x: true, forcePadLength: 64);
    } else if (value is String) {
      final hash = keccakUtf8(value);
      return bytesToHex(hash,
          padToEvenLength: true, include0x: true, forcePadLength: 64);
    } else {
      throw ArgumentError('Unsupported type for topic');
    }
  }

  Future<StreamSubscription<FilterEvent>> listenToGroupCreatedEvents(
      String contractAddress,
      Function(String, List<EthereumAddress>, String) handler) async {
    final DeployedContract deployedContract =
        await loadEscrowContract(contractAddress);
    return _listenToEvent(EscrowEvents.groupCreated.eventName, deployedContract,
        (List<dynamic> decoded) {
      final String groupName = decoded[0].toString();
      final List<EthereumAddress> members = (decoded[1] as List<dynamic>)
          .map((address) => address as EthereumAddress)
          .toList();
      final String memberContractAddress = decoded[2].toString();
      handler(groupName, members, memberContractAddress);
    });
  }

  Future<StreamSubscription<FilterEvent>> listenToGroupDisbandedEvents(
      String contractAddress,
      Function(String, List<EthereumAddress>, String) handler) async {
    final DeployedContract deployedContract =
        await loadEscrowContract(contractAddress);
    return _listenToEvent(
        EscrowEvents.groupDisbanded.eventName, deployedContract,
        (List<dynamic> decoded) {
      final String groupName = decoded[0].toString();
      final List<EthereumAddress> members = (decoded[1] as List<dynamic>)
          .map((address) => address as EthereumAddress)
          .toList();
      final String memberContractAddress = decoded[2].toString();
      handler(groupName, members, memberContractAddress);
    });
  }

  Future<StreamSubscription<FilterEvent>> listenToInitiateTransactionEvents(
      String contractAddress, Function(List<dynamic>) handler) async {
    final DeployedContract deployedContract =
        await loadEscrowContract(contractAddress);
    return _listenToEvent(
        EscrowEvents.transactionInitiated.eventName, deployedContract,
        (List<dynamic> decoded) {
      handler(decoded);
    });
  }

  Future<StreamSubscription<FilterEvent>> listenToApprovedTransactionEvents(
      String contractAddress, Function(List<dynamic>) handler) async {
    final DeployedContract deployedContract =
        await loadEscrowContract(contractAddress);
    return _listenToEvent(
        EscrowEvents.transactionApproved.eventName, deployedContract,
        (List<dynamic> decoded) {
      handler(decoded);
    });
  }

  Future<StreamSubscription<FilterEvent>> listenToDeclinedTransactionEvents(
      String contractAddress, Function(List<dynamic>) handler) async {
    final DeployedContract deployedContract =
        await loadEscrowContract(contractAddress);
    return _listenToEvent(
        EscrowEvents.transactionDeclined.eventName, deployedContract,
        (List<dynamic> decoded) {
      handler(decoded);
    });
  }

  Future<StreamSubscription<FilterEvent>> listenToExecutedTransactionEvents(
      String contractAddress, Function(List<dynamic>) handler) async {
    final DeployedContract deployedContract =
        await loadEscrowContract(contractAddress);
    return _listenToEvent(
        EscrowEvents.transactionExecuted.eventName, deployedContract,
        (List<dynamic> decoded) {
      handler(decoded);
    });
  }

  StreamSubscription<FilterEvent> listenToEscrowRegisteredEvents(
      Function(String, EthereumAddress, EthereumAddress) handler) {
    return _listenToEvent(
        EscrowEvents.escrowRegistered.eventName, escrowFactoryContract,
        (List<dynamic> decoded) {
      final String groupName = decoded[0].toString();
      final EthereumAddress memberContractAddress =
          decoded[1] as EthereumAddress;
      final EthereumAddress memberAddress = decoded[2] as EthereumAddress;
      handler(groupName, memberContractAddress, memberAddress);
    });
  }

  StreamSubscription<FilterEvent> listenToEscrowDeregisteredEvents(
      Function(String, EthereumAddress, EthereumAddress) handler) {
    return _listenToEvent(
        EscrowEvents.escrowDeregistered.eventName, escrowFactoryContract,
        (List<dynamic> decoded) {
      final String groupName = decoded[0].toString();
      final EthereumAddress memberContractAddress =
          decoded[1] as EthereumAddress;
      final EthereumAddress memberAddress = decoded[2] as EthereumAddress;
      handler(groupName, memberContractAddress, memberAddress);
    });
  }

  StreamSubscription<FilterEvent> _listenToEvent(String eventName,
      DeployedContract deployedContract, Function(List<dynamic>) decoder) {
    final event = deployedContract.event(eventName);
    return _client
        .events(FilterOptions.events(contract: deployedContract, event: event))
        .listen((filterEvent) {
      final decoded =
          event.decodeResults(filterEvent.topics!, filterEvent.data!);
      decoder(decoded);
    });
  }
}
