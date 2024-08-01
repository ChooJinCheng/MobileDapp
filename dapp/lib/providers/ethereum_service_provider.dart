import 'package:dapp/services/ethereum_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final ethereumServiceProvider = Provider<EthereumService>((ref) {
  return EthereumService(
      rpcUrl: 'http://10.0.2.2:7545',
      privateKey:
          '0xe3dc50c0f47c8002acbc69a190092a4292005ad8c80f515a7d1599d662ba4643');
});
