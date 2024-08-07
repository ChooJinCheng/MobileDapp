import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:dapp/services/ethereum_abi_loader.dart';
import 'package:dapp/enum/escrow_factory_functions.dart';

class EthereumService {
  static final EthereumService _instance = EthereumService._internal();
  static const int _chainID = 1337;
  late String rpcUrl;
  late String privateKey;
  late String factoryContractAddress;
  late DeployedContract escrowContract;
  late Web3Client _client;
  late EthPrivateKey _credentials;

  EthereumService._internal();

  factory EthereumService(
      {required String rpcUrl,
      required String privateKey,
      required String factoryContractAddress}) {
    _instance.rpcUrl = rpcUrl;
    _instance.privateKey = privateKey;
    _instance.factoryContractAddress = factoryContractAddress;
    _instance._initialize();
    return _instance;
  }

  void _initialize() async {
    _client = Web3Client(rpcUrl, Client());
    _credentials = EthPrivateKey.fromHex(privateKey);

    DeployedContract factoryContract = await _instance.loadFactoryContract();
    final response = await _instance.query(factoryContract,
        EscrowFactoryFunctions.getEscrow.functionName, [], true);
    String address = response[0].toString();
    if (address != '0x0000000000000000000000000000000000000000') {
      escrowContract = await _instance.loadContract(
          'lib/services/ethereum_contract_json/escrow_abi.json', address);
      print('Deployed Escrow Contract At: $address');
    } else {
      print('No Escrow Contract Deployed');
    }
  }

  EthereumAddress get userAddress => _credentials.address;

  Future<DeployedContract> loadContract(
      String abiPath, String contractAddress) async {
    final abiString = await loadAbi(abiPath);
    final contract = DeployedContract(
      ContractAbi.fromJson(abiString, 'MyContract'),
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

  callFunction(DeployedContract contract, String functionName,
      List<dynamic> args) async {
    final function = contract.function(functionName);
    final result = await _client.sendTransaction(
      _credentials,
      Transaction.callContract(
        contract: contract,
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
        await Future.delayed(Duration(seconds: 1));
      }
    }

    print('Txn Receipt: $receipt');
    print('Txn Receipt contract addr: ${receipt.contractAddress}');
    print('Txn Receipt logs: ${receipt.logs}');

    return result;
  }

  Future<List<dynamic>> query(DeployedContract contract, String functionName,
      List<dynamic> args, bool sendAddress) async {
    if (sendAddress) {
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

  void listenToGroupCreatedEvents(Function(String, EthereumAddress) handler) {
    _listenToEvent('GroupCreated', (List<dynamic> decoded) {
      final groupName = decoded[0] as String;
      final owner = decoded[1] as EthereumAddress;
      handler(groupName, owner);
    });
  }

  void _listenToEvent(String eventName, Function(List<dynamic>) decoder) {
    final event = escrowContract.event(eventName);
    _client
        .events(FilterOptions.events(contract: escrowContract, event: event))
        .listen((filterEvent) {
      final decoded =
          event.decodeResults(filterEvent.topics!, filterEvent.data!);
      decoder(decoded);
    });
  }
}
