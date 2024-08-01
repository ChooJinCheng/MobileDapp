import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:dapp/services/ethereum_abi_loader.dart';

class EthereumService {
  static final EthereumService _instance = EthereumService._internal();
  static const int _chainID = 1337;
  late String rpcUrl;
  late String privateKey;
  late Web3Client _client;
  late EthPrivateKey _credentials;

  EthereumService._internal();

  factory EthereumService(
      {required String rpcUrl, required String privateKey}) {
    _instance.rpcUrl = rpcUrl;
    _instance.privateKey = privateKey;
    _instance._initialize();
    return _instance;
  }

  void _initialize() {
    _client = Web3Client(rpcUrl, Client());
    _credentials = EthPrivateKey.fromHex(privateKey);
  }

  Future<void> testConnectionAndAccount() async {
    try {
      final version = await _client.getClientVersion();
      print('Connected to: $version');

      final address = _credentials.address;
      final balance = await _client.getBalance(address);
      print('Account: $address');
      print('Balance: $balance');
    } catch (e) {
      print('Connection failed: $e');
    }
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

  Future<List<dynamic>> query(
    DeployedContract contract,
    String functionName,
    List<dynamic> args,
  ) async {
    final ethFunction = contract.function(functionName);
    final result = await _client.call(
      contract: contract,
      function: ethFunction,
      params: args,
    );
    return result;
  }
}
