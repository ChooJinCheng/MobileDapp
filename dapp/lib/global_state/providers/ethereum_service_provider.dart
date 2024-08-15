import 'package:dapp/services/ethereum_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final ethereumServiceProvider = Provider<EthereumService>((ref) {
  return EthereumService(
      rpcUrl: 'http://10.0.2.2:7545',
      privateKey:
          '0x243881ef9e0b2105616bf1b628bfa6506345e784761e9629bb82667288bafbb7',
      factoryContractAddress: '0x0D5102c112ac7f26558d7ACBf3Bb2599B12e28e0');
});
