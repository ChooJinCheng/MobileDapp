import 'package:dapp/services/ethereum_service';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final ethereumServiceProvider = Provider<EthereumService>((ref) {
  return EthereumService(
      rpcUrl: 'http://127.0.0.1:7545',
      privateKey:
          '0x03ff0aeed706ead02968e13f5592588bbedb59a3a80adca9a6003c790e82cb48');
});
