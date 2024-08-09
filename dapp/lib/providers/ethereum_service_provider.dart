import 'package:dapp/services/ethereum_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final ethereumServiceProvider = Provider<EthereumService>((ref) {
  return EthereumService(
      rpcUrl: 'http://10.0.2.2:7545',
      privateKey:
          '0x9ebb1bf9a075119a09dae678285506988d782818d435c7e1028baef99816e008',
      factoryContractAddress: '0x5Fc66F2340CBC02765886F74a1C12B672741d531');
});
