import 'package:dapp/global_state/notifiers/transaction_state_notifier.dart';
import 'package:dapp/global_state/providers/event_listener_manager_provider.dart';
import 'package:dapp/global_state/providers/transaction_service_provider.dart';
import 'package:dapp/model/user_transaction_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final transactionStateProvider = StateNotifierProvider<TransactionNotifier,
    Map<String, Map<String, List<UserTransaction>>>>((ref) {
  final transactionService = ref.watch(transactionServiceProvider);
  final eventListenerManager = ref.watch(eventListenerManagerProvider);
  return TransactionNotifier(transactionService, eventListenerManager);
});
