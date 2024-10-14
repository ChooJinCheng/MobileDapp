import 'package:dapp/services/wallet_connection_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final walletConnectionServiceProvider =
    Provider<WalletConnectionService>((ref) {
  return WalletConnectionService();
});
