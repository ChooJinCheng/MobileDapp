import 'package:dapp/model/user_transaction_model.dart';
import 'package:dapp/services/event_listener_manager.dart';
import 'package:dapp/services/transaction_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TransactionNotifier
    extends StateNotifier<Map<String, Map<String, List<UserTransaction>>>> {
  final TransactionService transactionService;
  final EventListenerManager eventListenerManager;

  TransactionNotifier(this.transactionService, this.eventListenerManager)
      : super({}) {}

  bool get isEmpty => state.isEmpty;

  Future<void> loadGroupTransactions(
      String groupID, String groupName, String groupContractAddress) async {
    Map<String, List<UserTransaction>> groupToTransactionsMap =
        await transactionService.fetchGroupTransactions(
            groupName, groupContractAddress);
    state = {groupID: groupToTransactionsMap};
  }
}
