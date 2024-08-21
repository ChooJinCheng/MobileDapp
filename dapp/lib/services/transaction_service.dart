import 'package:dapp/enum/escrow_events.dart';
import 'package:dapp/enum/escrow_functions.dart';
import 'package:dapp/enum/transaction_category_enum.dart';
import 'package:dapp/enum/transaction_status_enum.dart';
import 'package:dapp/model/event_approved_transaction_model.dart';
import 'package:dapp/model/event_declined_transaction_model.dart';
import 'package:dapp/model/event_executed_transaction_model.dart';
import 'package:dapp/model/user_transaction_model.dart';
import 'package:dapp/services/ethereum_service.dart';
import 'package:web3dart/web3dart.dart';

class TransactionService {
  final EthereumService _ethereumService;

  TransactionService(this._ethereumService);

  EthereumAddress get userAddress => _ethereumService.userAddress;
  EthereumAddress get escrowAddress => _ethereumService.escrowAddress;

  Future<void> initiateNewTransaction(
      String groupContractAddress, List<dynamic> args) async {
    await _ethereumService.callFunction(groupContractAddress,
        EscrowFunctions.initiateTransaction.functionName, args);
  }

  Future<Map<String, List<UserTransaction>>> fetchGroupTransactions(
      String groupName, String groupContractAddress) async {
    Map<String, List<UserTransaction>> statusToTransactions = {
      'pendingStatus': [],
      'otherStatus': []
    };

    List<UserTransaction> initTransactions = [];
    List<EventDeclinedTransaction> declinedTransactions = [];
    List<EventApprovedTransaction> approvedTransactions = [];
    List<EventExecutedTransaction> executedTransactions = [];

    DateTime now = DateTime.now();
    int range = 3;
    int month = now.month;
    int year = now.year;

    for (int i = 0; i < range; i++) {
      List<dynamic> args = [groupName, month, year];
      // Retrieve the events
      declinedTransactions.addAll(await _queryTransactionDeclined(
          groupName, groupContractAddress, args));
      approvedTransactions.addAll(await _queryTransactionApproved(
          groupName, groupContractAddress, args));
      executedTransactions.addAll(await _queryTransactionExecuted(
          groupName, groupContractAddress, args));
      initTransactions.addAll(await _queryTransactionInitiate(
          groupName, groupContractAddress, args));

      month--;
      if (month < 1) {
        month = 12;
        year--;
      }
    }

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
    );

    for (EventExecutedTransaction executedTxn in executedTransactions) {
      UserTransaction txn = initTransactions.firstWhere(
        (txn) => txn.transactID == executedTxn.transactID,
        orElse: () => dummyTransaction,
      );

      if (txn.transactID.isNotEmpty) {
        txn.transactStatus = TransactionStatus.approved;
        statusToTransactions['otherStatus']!.add(txn);
        initTransactions.remove(txn);
      }
    }

// Decline step
    for (EventDeclinedTransaction declinedTxn in declinedTransactions) {
      UserTransaction txn = initTransactions.firstWhere(
        (txn) => txn.transactID == declinedTxn.transactID,
        orElse: () => dummyTransaction,
      );

      if (txn.transactID.isNotEmpty) {
        txn.transactStatus = TransactionStatus.declined;
        statusToTransactions['otherStatus']!.add(txn);
        initTransactions.remove(txn);
      }
    }

    for (UserTransaction txn in initTransactions) {
      var approved = approvedTransactions
          .where((approvedTxn) => approvedTxn.transactID == txn.transactID);

      bool isUserInvolved =
          approved.any((approvedTxn) => approvedTxn.approver == userAddress) ||
              EthereumAddress.fromHex(txn.transactPayee) == userAddress;

      if (isUserInvolved || !txn.transactPayers.contains(userAddress)) {
        statusToTransactions['otherStatus']!.add(txn);
      } else {
        statusToTransactions['pendingStatus']!.add(txn);
      }
    }

    for (String key in statusToTransactions.keys) {
      statusToTransactions[key]!.sort((a, b) => b.date.compareTo(a.date));
    }

    for (String key in statusToTransactions.keys) {
      List<UserTransaction> txns = statusToTransactions[key]!;
      print('Key: $key');
      print('size: ${txns.length}');
      for (var txn in txns) {
        print('Txn: ${txn.groupName}');
        print('TxnID: ${txn.transactID}');
        print('date: ${txn.date}');
        print('transactStatus: ${txn.transactStatus}');
        print('-----------------------');
      }
    }
    return statusToTransactions;
  }

  Future<List<UserTransaction>> _queryTransactionInitiate(
      String groupName, String groupContractAddress, List<dynamic> args) async {
    final decodedLogs = await _ethereumService.queryEventLogs(
        groupContractAddress,
        EscrowEvents.transactionInitiated.eventName,
        args);

    List<UserTransaction> userTransactions = decodedLogs.map((decoded) {
      int day = (decoded[0] as BigInt).toInt();
      int month = (decoded[1] as BigInt).toInt();
      int year = (decoded[2] as BigInt).toInt();
      TransactionStatus transactionStatus =
          TransactionStatusExtension.fromInt((decoded[3] as BigInt).toInt());
      EthereumAddress payee = decoded[6] as EthereumAddress;
      List<EthereumAddress> payers = (decoded[7] as List<dynamic>)
          .map((address) => address as EthereumAddress)
          .toList();
      BigInt totalAmount = decoded[9] as BigInt;
      TransactionCategory transactionCategory =
          TransactionCategoryExtension.fromInt((decoded[10] as BigInt).toInt());
      EthereumAddress userAddress = _ethereumService.userAddress;
      bool transactionType = (payee == userAddress) ? true : false;
      BigInt requiredApproval = (decoded[11] as BigInt) + BigInt.one;
      double transactAmount = totalAmount / (requiredApproval);
      return UserTransaction(
          date: DateTime(year, month, day),
          groupName: groupName,
          transactStatus: transactionStatus,
          transactID: decoded[4].toString(),
          transactInitiator: decoded[5].toString(),
          transactPayee: payee.toString(),
          transactPayers: payers,
          transactTitle: decoded[8].toString(),
          totalAmount: totalAmount.toString(),
          category: transactionCategory,
          transactionType: transactionType,
          transactAmount: transactAmount.toStringAsFixed(2));
    }).toList();

    return userTransactions;
  }

  Future<List<EventApprovedTransaction>> _queryTransactionApproved(
      String groupName, String groupContractAddress, List<dynamic> args) async {
    final decodedLogs = await _ethereumService.queryEventLogs(
        groupContractAddress, EscrowEvents.transactionApproved.eventName, args);

    List<EventApprovedTransaction> approvedEvents = decodedLogs.map((decoded) {
      int day = (decoded[0] as BigInt).toInt();
      int month = (decoded[1] as BigInt).toInt();
      int year = (decoded[2] as BigInt).toInt();
      return EventApprovedTransaction(
          groupName: groupName,
          date: DateTime(year, month, day),
          transactID: decoded[3].toString(),
          approver: decoded[4] as EthereumAddress);
    }).toList();

    return approvedEvents;
  }

  Future<List<EventDeclinedTransaction>> _queryTransactionDeclined(
      String groupName, String groupContractAddress, List<dynamic> args) async {
    final decodedLogs = await _ethereumService.queryEventLogs(
        groupContractAddress, EscrowEvents.transactionDeclined.eventName, args);

    List<EventDeclinedTransaction> declinedEvents = decodedLogs.map((decoded) {
      int day = (decoded[0] as BigInt).toInt();
      int month = (decoded[1] as BigInt).toInt();
      int year = (decoded[2] as BigInt).toInt();
      TransactionStatus transactionStatus =
          TransactionStatusExtension.fromInt((decoded[4] as BigInt).toInt());
      return EventDeclinedTransaction(
          groupName: groupName,
          date: DateTime(year, month, day),
          transactID: decoded[3].toString(),
          transactStatus: transactionStatus);
    }).toList();

    return declinedEvents;
  }

  Future<List<EventExecutedTransaction>> _queryTransactionExecuted(
      String groupName, String groupContractAddress, List<dynamic> args) async {
    final decodedLogs = await _ethereumService.queryEventLogs(
        groupContractAddress, EscrowEvents.transactionExecuted.eventName, args);

    List<EventExecutedTransaction> executedEvents = decodedLogs.map((decoded) {
      int day = (decoded[0] as BigInt).toInt();
      int month = (decoded[1] as BigInt).toInt();
      int year = (decoded[2] as BigInt).toInt();
      TransactionStatus transactionStatus =
          TransactionStatusExtension.fromInt((decoded[4] as BigInt).toInt());
      return EventExecutedTransaction(
          groupName: groupName,
          date: DateTime(year, month, day),
          transactID: decoded[3].toString(),
          transactStatus: transactionStatus);
    }).toList();

    return executedEvents;
  }
}
