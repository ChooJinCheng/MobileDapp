import 'package:dapp/global_state/providers/wallet_connection_service_provider.dart';
import 'package:dapp/services/ethereum_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final ethereumServiceProvider = Provider<EthereumService>((ref) {
  final walletConnectionService = ref.read(walletConnectionServiceProvider);
  return EthereumService(
      walletConnectionService: walletConnectionService,
      factoryContractAddress: '0x5FbDB2315678afecb367f032d93F642f64180aa3',
      usdcContractAddress: '0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512');
});
