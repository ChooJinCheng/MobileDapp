import 'package:dapp/services/ethereum_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final ethereumServiceProvider = Provider<EthereumService>((ref) {
  return EthereumService(
      rpcUrl: 'http://10.0.2.2:7545',
      privateKey:
          '0xab9ff16b392733d7051b6ad2a684f4acb12d27228f922c305ab7ef84fa6c57a8',
      factoryContractAddress: '0xa41712F549cD6AEeeEb52b5Cc1533d19111b1afe');
});
