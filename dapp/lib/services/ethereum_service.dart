import 'dart:async';

import 'package:dapp/custom_exception/custom_exception.dart';
import 'package:dapp/enum/erc20_usdc_functions.dart';
import 'package:dapp/enum/escrow_events.dart';
import 'package:dapp/services/wallet_connection_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'package:web3dart/crypto.dart';
import 'package:dapp/services/ethereum_abi_loader.dart';
import 'package:dapp/enum/escrow_factory_functions.dart';

class EthereumService {
  static final EthereumService _instance = EthereumService._internal();
  late WalletConnectionService _walletConnectionService;
  //static const int _chainID = 1337;
  late String _rpcUrl;
  late String factoryContractAddress;
  late String usdcContractAddress;
  late DeployedContract escrowContract;
  late DeployedContract escrowFactoryContract;
  late DeployedContract usdcContract;
  late Web3Client _client;
  late String _userConnectedAddress;

  EthereumService._internal();

  factory EthereumService(
      {required WalletConnectionService walletConnectionService,
      required String factoryContractAddress,
      required String usdcContractAddress}) {
    _instance.factoryContractAddress = factoryContractAddress;
    _instance.usdcContractAddress = usdcContractAddress;
    _instance._walletConnectionService = walletConnectionService;
    //_instance._initialize();
    return _instance;
  }

  Future<void> initialize() async {
    try {
      if (!_walletConnectionService.isConnected) {
        throw GeneralException('Wallet is not connected');
      }
      // debugPrint(
      //     '[Splidapp.ethereum_service] Rpc URL: ${_walletConnectionService.appKitModal.selectedChain?.rpcUrl}');
      _rpcUrl = 'http://10.0.2.2:8545';
      _client = Web3Client(_rpcUrl, Client());
      _userConnectedAddress = _walletConnectionService.connectedAddress!;

      usdcContract = await _instance.loadUSDCContract();
      escrowFactoryContract = await _instance.loadFactoryContract();
      final response = await _instance.query(escrowFactoryContract,
          EscrowFactoryFunctions.getEscrow.functionName, [], true);
      String address = response[0].toString();

      if (address != '0x0000000000000000000000000000000000000000') {
        escrowContract = await _instance.loadEscrowContract(address);
        debugPrint(
            '[Splidapp.ethereum_service] Escrow Contract is already deployed at: $address');
      } else {
        await deployEscrowContract(escrowFactoryContract);
        final address = await query(escrowFactoryContract,
            EscrowFactoryFunctions.getEscrow.functionName, [], true);
        escrowContract =
            await _instance.loadEscrowContract(address[0].toString());
        debugPrint(
            '[Splidapp.ethereum_service] Newly deployed escrow at: $address');
      }
      debugPrint('[Splidapp.ethereum_service] EthereumService Initialized');
      return;
    } catch (e) {
      if (e is RPCError) {
        String errorMessage = _parseRPCErrorMessage(e.message);
        throw RpcException(errorMessage);
      }
      throw GeneralException('Unexpected error: $e');
    }
  }

  EthereumAddress get userAddress =>
      EthereumAddress.fromHex(_userConnectedAddress);
  EthereumAddress get escrowAddress => escrowContract.address;

  Future<dynamic> deployEscrowContract(DeployedContract factoryContract) async {
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

  Future<DeployedContract> loadUSDCContract() async {
    final abiString =
        await loadAbi('lib/services/ethereum_contract_json/usdc_abi.json');
    final contract = DeployedContract(
      ContractAbi.fromJson(abiString, 'UsdcContract'),
      EthereumAddress.fromHex(usdcContractAddress),
    );
    return contract;
  }

  callFunction(
      String contractAddress, String functionName, List<dynamic> args) async {
    DeployedContract deployedContract;

    if (functionName == EscrowFactoryFunctions.deployEscrow.functionName) {
      deployedContract = await loadFactoryContract();
    } else if (functionName == Erc20UsdcFunctions.approve.functionName) {
      deployedContract = await loadUSDCContract();
    } else {
      deployedContract = await loadEscrowContract(contractAddress);
    }

    //final function = deployedContract.function(functionName);

    try {
      _walletConnectionService.appKitModal.launchConnectedWallet();

      final result =
          await _walletConnectionService.appKitModal.requestWriteContract(
        topic: _walletConnectionService.appKitModal.session!.topic,
        chainId: _walletConnectionService.appKitModal.selectedChain!.chainId,
        deployedContract: deployedContract,
        functionName: functionName,
        transaction: Transaction(
          from: EthereumAddress.fromHex(
              _walletConnectionService.appKitModal.session!.address!),
        ),
        parameters: args,
      );
      /* final result = await _client.sendTransaction(
        _credentials,
        Transaction.callContract(
          contract: deployedContract,
          function: function,
          parameters: args,
          maxGas: 6721975,
        ),
        chainId: _chainID,
      ); */

      return result;
    } catch (e) {
      if (e is RPCError) {
        String errorMessage = _parseRPCErrorMessage(e.message);
        throw RpcException(errorMessage);
      }
      throw GeneralException('Unexpected error: $e');
    }
  }

  Future<List<dynamic>> query(DeployedContract contract, String functionName,
      List<dynamic> args, bool sendUserAddress) async {
    if (sendUserAddress) {
      args.add(EthereumAddress.fromHex(_userConnectedAddress));
    }
    try {
      final ethFunction = contract.function(functionName);
      final result = await _client.call(
          contract: contract,
          function: ethFunction,
          params: args,
          sender: EthereumAddress.fromHex(_userConnectedAddress));
      return result;
    } catch (e) {
      if (e is RPCError) {
        String errorMessage = _parseRPCErrorMessage(e.message);
        throw RpcException(errorMessage);
      }
      throw GeneralException('Unexpected error: $e');
    }
  }

  String _parseRPCErrorMessage(String message) {
    if (message.contains('revert')) {
      final parts = message.split('revert');
      if (parts.length > 1) {
        return parts[1].trim();
      }
      return 'Transaction reverted without a message.';
    }
    return message;
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
