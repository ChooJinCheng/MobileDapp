import 'package:dapp/enum/transaction_category_enum.dart';
import 'package:dapp/enum/transaction_grouping_status_enum.dart';
import 'package:dapp/enum/transaction_status_enum.dart';
import 'package:dapp/event_bus/event_bus_singleton.dart';
import 'package:dapp/model/event_approved_transaction_model.dart';
import 'package:dapp/model/event_declined_transaction_model.dart';
import 'package:dapp/model/event_executed_transaction_model.dart';
import 'package:dapp/model/user_transaction_model.dart';
import 'package:dapp/services/event_listener_manager.dart';
import 'package:dapp/services/group_service.dart';
import 'package:dapp/services/transaction_service.dart';
import 'package:dapp/utils/utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web3dart/web3dart.dart';

class TransactionNotifier
    extends StateNotifier<Map<String, Map<String, List<UserTransaction>>>> {
  final GroupService groupService;
  final TransactionService transactionService;
  final EventListenerManager eventListenerManager;

  TransactionNotifier(
      this.groupService, this.transactionService, this.eventListenerManager)
      : super({}) {
    _listenToBusAndEscrows();
  }

  bool get isEmpty => state.isEmpty;
  bool isExist(String groupID) => state.containsKey(groupID);

  Future<void> loadGroupTransactions(
      String groupID, String groupName, String groupContractAddress) async {
    Map<String, List<UserTransaction>> groupToTransactionsMap =
        await transactionService.fetchGroupTransactions(
            groupName, groupContractAddress);
    state = {...state, groupID: groupToTransactionsMap};
  }

  _listenToBusAndEscrows() async {
    List<String> escrowAddresses =
        await groupService.fetchEscrowMembershipAddresses();
    escrowAddresses.add(transactionService.escrowAddress.toString());

    for (String address in escrowAddresses) {
      _listenToGroupEvents(address);
    }

    AppEventBus.instance.on<EscrowRegisteredEvent>().listen((event) {
      _listenToGroupEvents(event.memberContractAddress);
    });

    AppEventBus.instance.on<GroupDisbandedEvent>().listen((event) {
      if (state.containsKey(event.groupID)) {
        final newState =
            Map<String, Map<String, List<UserTransaction>>>.from(state);
        newState.remove(event.groupID);
        state = newState;
      }
    });
  }

  _listenToGroupEvents(String address) {
    eventListenerManager.listenToInitiateTransactionEvents(
        address, _handleInitiateTransactions);
    eventListenerManager.listenToApprovedTransactionEvents(
        address, _handleApprovedTransactions);
    eventListenerManager.listenToDeclinedTransactionEvents(
        address, _handleDeclinedTransactions);
    eventListenerManager.listenToExecutedTransactionEvents(
        address, _handleExecutedTransactions);
  }

  void _handleInitiateTransactions(List<dynamic> decoded) {
    EthereumAddress memberContractAddress = decoded[13] as EthereumAddress;
    UserTransaction transaction =
        transactionService.decodeUserTransaction(decoded);

    String groupID = Utils.generateUniqueID(
        transaction.groupName, memberContractAddress.toString());
    if (!state.containsKey(groupID)) return;

    _addTransaction(groupID, transaction);
  }

  void _addTransaction(String groupID, UserTransaction transaction) {
    Map<String, List<UserTransaction>> currentGroupState =
        Map<String, List<UserTransaction>>.from(state[groupID]!);
    EthereumAddress currentUserAddress = transactionService.userAddress;

    List<UserTransaction> pendingTransactions = List<UserTransaction>.from(
        currentGroupState[TransactionGroupingStatus.pendingStatus.name]!);

    List<UserTransaction> otherTransactions = List<UserTransaction>.from(
        currentGroupState[TransactionGroupingStatus.otherStatus.name]!);

    if (transaction.transactPayers.contains(currentUserAddress)) {
      pendingTransactions.add(transaction);
      pendingTransactions.sort((a, b) => b.date.compareTo(a.date));
    } else {
      otherTransactions.add(transaction);
      otherTransactions.sort((a, b) => b.date.compareTo(a.date));
    }

    final newState =
        Map<String, Map<String, List<UserTransaction>>>.from(state);
    newState[groupID] = {
      TransactionGroupingStatus.pendingStatus.name: pendingTransactions,
      TransactionGroupingStatus.otherStatus.name: otherTransactions,
    };

    state = newState;
  }

  void _handleApprovedTransactions(List<dynamic> decoded) {
    EthereumAddress memberContractAddress = decoded[6] as EthereumAddress;
    EventApprovedTransaction eventApproved =
        transactionService.decodeEventApprovedTransaction(decoded);
    if (eventApproved.approver != transactionService.userAddress) return;

    String groupID = Utils.generateUniqueID(
        eventApproved.groupName, memberContractAddress.toString());
    if (!state.containsKey(groupID)) return;

    _updateTransaction(
        groupID, eventApproved.transactID, TransactionStatus.pending);
  }

  void _handleDeclinedTransactions(List<dynamic> decoded) {
    EthereumAddress memberContractAddress = decoded[6] as EthereumAddress;
    EventDeclinedTransaction eventDeclined =
        transactionService.decodeEventDeclinedTransaction(decoded);
    if (eventDeclined.transactStatus != TransactionStatus.declined) return;

    String groupID = Utils.generateUniqueID(
        eventDeclined.groupName, memberContractAddress.toString());
    if (!state.containsKey(groupID)) return;

    _updateTransaction(
        groupID, eventDeclined.transactID, TransactionStatus.declined);
  }

  void _handleExecutedTransactions(List<dynamic> decoded) {
    EthereumAddress memberContractAddress = decoded[6] as EthereumAddress;
    EventExecutedTransaction eventExecuted =
        transactionService.decodeEventExecutedTransaction(decoded);
    if (eventExecuted.transactStatus != TransactionStatus.approved) return;

    String groupID = Utils.generateUniqueID(
        eventExecuted.groupName, memberContractAddress.toString());
    if (!state.containsKey(groupID)) return;

    _updateTransaction(
        groupID, eventExecuted.transactID, TransactionStatus.approved);
    AppEventBus.instance.fire(TransactionExecutedEvent(groupID));
  }

  void _updateTransaction(
      String groupID, String transactID, TransactionStatus newStatus) {
    Map<String, List<UserTransaction>> currentGroupState =
        Map<String, List<UserTransaction>>.from(state[groupID] ?? {});

    if (currentGroupState.isEmpty) return;

    UserTransaction dummyTransaction = UserTransaction(
      date: DateTime(1970, 1, 1),
      groupName: '',
      transactStatus: TransactionStatus.pending,
      transactID: '',
      transactInitiator: '',
      transactPayee: '',
      transactPayers: [],
      transactTitle: '',
      totalAmount: '',
      category: TransactionCategory.activity,
      transactionType: false,
      transactAmount: '',
      isInvolved: false,
    );

    List<UserTransaction> pendingTransactions = List<UserTransaction>.from(
        currentGroupState[TransactionGroupingStatus.pendingStatus.name] ?? []);

    List<UserTransaction> otherTransactions = List<UserTransaction>.from(
        currentGroupState[TransactionGroupingStatus.otherStatus.name] ?? []);

    if (pendingTransactions.isEmpty && otherTransactions.isEmpty) return;

    UserTransaction? transaction = pendingTransactions.firstWhere(
      (transaction) => transaction.transactID == transactID,
      orElse: () => dummyTransaction,
    );

    if (transaction.transactID.isNotEmpty) {
      pendingTransactions.remove(transaction);

      transaction.transactStatus = newStatus;
      otherTransactions.add(transaction);
      otherTransactions.sort((a, b) => b.date.compareTo(a.date));
    } else {
      transaction = otherTransactions.firstWhere(
        (transaction) => transaction.transactID == transactID,
        orElse: () => dummyTransaction,
      );
      transaction.transactStatus = newStatus;
    }

    final newState =
        Map<String, Map<String, List<UserTransaction>>>.from(state);
    newState[groupID] = {
      TransactionGroupingStatus.pendingStatus.name: pendingTransactions,
      TransactionGroupingStatus.otherStatus.name: otherTransactions,
    };
    state = newState;
  }
}
