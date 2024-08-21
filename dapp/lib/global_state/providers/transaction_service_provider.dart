import 'package:dapp/global_state/providers/ethereum_service_provider.dart';
import 'package:dapp/services/transaction_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final transactionServiceProvider = Provider<TransactionService>((ref) {
  final ethereumService = ref.watch(ethereumServiceProvider);
  return TransactionService(ethereumService);
});
