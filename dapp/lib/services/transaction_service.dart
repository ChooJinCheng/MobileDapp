import 'package:dapp/enum/escrow_events.dart';
import 'package:dapp/enum/escrow_functions.dart';
import 'package:dapp/enum/transaction_category_enum.dart';
import 'package:dapp/enum/transaction_grouping_status_enum.dart';
import 'package:dapp/enum/transaction_status_enum.dart';
import 'package:dapp/model/event_approved_transaction_model.dart';
import 'package:dapp/model/event_declined_transaction_model.dart';
import 'package:dapp/model/event_executed_transaction_model.dart';
import 'package:dapp/model/user_transaction_model.dart';
import 'package:dapp/services/ethereum_service.dart';
import 'package:dapp/utils/decimal_bigint_converter.dart';
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

  Future<void> approveTransaction(
      String groupContractAddress, List<dynamic> args) async {
    await _ethereumService.callFunction(groupContractAddress,
        EscrowFunctions.approveTransaction.functionName, args);
  }

  Future<void> declineTransaction(
      String groupContractAddress, List<dynamic> args) async {
    await _ethereumService.callFunction(groupContractAddress,
        EscrowFunctions.declineTransaction.functionName, args);
  }

  Future<Map<String, List<UserTransaction>>> fetchGroupTransactions(
      String groupName, String groupContractAddress) async {
    Map<String, List<UserTransaction>> statusToTransactions = {
      TransactionGroupingStatus.pendingStatus.name: [],
      TransactionGroupingStatus.otherStatus.name: []
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

      declinedTransactions
          .addAll(await _queryTransactionDeclined(groupContractAddress, args));
      approvedTransactions
          .addAll(await _queryTransactionApproved(groupContractAddress, args));
      executedTransactions
          .addAll(await _queryTransactionExecuted(groupContractAddress, args));
      initTransactions
          .addAll(await _queryTransactionInitiate(groupContractAddress, args));

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
      isInvolved: false,
    );

    for (EventExecutedTransaction executedTxn in executedTransactions) {
      UserTransaction txn = initTransactions.firstWhere(
        (txn) => txn.transactID == executedTxn.transactID,
        orElse: () => dummyTransaction,
      );

      if (txn.transactID.isNotEmpty) {
        txn.transactStatus = TransactionStatus.approved;
        statusToTransactions[TransactionGroupingStatus.otherStatus.name]!
            .add(txn);
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
        statusToTransactions[TransactionGroupingStatus.otherStatus.name]!
            .add(txn);
        initTransactions.remove(txn);
      }
    }

    for (UserTransaction txn in initTransactions) {
      Iterable<EventApprovedTransaction> approved = approvedTransactions
          .where((approvedTxn) => approvedTxn.transactID == txn.transactID);

      bool isUserInvolved =
          approved.any((approvedTxn) => approvedTxn.approver == userAddress) ||
              EthereumAddress.fromHex(txn.transactPayee) == userAddress;

      if (isUserInvolved || !txn.transactPayers.contains(userAddress)) {
        statusToTransactions[TransactionGroupingStatus.otherStatus.name]!
            .add(txn);
      } else {
        statusToTransactions[TransactionGroupingStatus.pendingStatus.name]!
            .add(txn);
      }
    }

    for (String key in statusToTransactions.keys) {
      statusToTransactions[key]!.sort((a, b) => b.date.compareTo(a.date));
    }

    return statusToTransactions;
  }

  Future<List<UserTransaction>> _queryTransactionInitiate(
      String groupContractAddress, List<dynamic> args) async {
    final decodedLogs = await _ethereumService.queryEventLogs(
        groupContractAddress,
        EscrowEvents.transactionInitiated.eventName,
        args);

    List<UserTransaction> userTransactions = decodedLogs.map((decoded) {
      return decodeUserTransaction(decoded);
    }).toList();

    return userTransactions;
  }

  Future<List<EventApprovedTransaction>> _queryTransactionApproved(
      String groupContractAddress, List<dynamic> args) async {
    final decodedLogs = await _ethereumService.queryEventLogs(
        groupContractAddress, EscrowEvents.transactionApproved.eventName, args);

    List<EventApprovedTransaction> approvedEvents = decodedLogs.map((decoded) {
      return decodeEventApprovedTransaction(decoded);
    }).toList();

    return approvedEvents;
  }

  Future<List<EventDeclinedTransaction>> _queryTransactionDeclined(
      String groupContractAddress, List<dynamic> args) async {
    final decodedLogs = await _ethereumService.queryEventLogs(
        groupContractAddress, EscrowEvents.transactionDeclined.eventName, args);

    List<EventDeclinedTransaction> declinedEvents = decodedLogs.map((decoded) {
      return decodeEventDeclinedTransaction(decoded);
    }).toList();

    return declinedEvents;
  }

  Future<List<EventExecutedTransaction>> _queryTransactionExecuted(
      String groupContractAddress, List<dynamic> args) async {
    final decodedLogs = await _ethereumService.queryEventLogs(
        groupContractAddress, EscrowEvents.transactionExecuted.eventName, args);

    List<EventExecutedTransaction> executedEvents = decodedLogs.map((decoded) {
      return decodeEventExecutedTransaction(decoded);
    }).toList();

    return executedEvents;
  }

  UserTransaction decodeUserTransaction(List<dynamic> decoded) {
    int day = (decoded[0] as BigInt).toInt();
    int month = (decoded[1] as BigInt).toInt();
    int year = (decoded[2] as BigInt).toInt();
    String groupName = decoded[3] as String;
    TransactionStatus transactionStatus =
        TransactionStatusExtension.fromInt((decoded[4] as BigInt).toInt());
    String transactionID = decoded[5].toString();
    String transactionInitiator = decoded[6].toString();
    EthereumAddress payee = decoded[7] as EthereumAddress;
    List<EthereumAddress> payers = (decoded[8] as List<dynamic>)
        .map((address) => address as EthereumAddress)
        .toList();
    String transactionTitle = decoded[9].toString();
    BigInt totalAmount = decoded[10] as BigInt;
    String totalAmountDecimal =
        DecimalBigIntConverter.bigIntToDecimal(totalAmount).toStringAsFixed(2);
    TransactionCategory transactionCategory =
        TransactionCategoryExtension.fromInt((decoded[11] as BigInt).toInt());
    EthereumAddress userAddress = _ethereumService.userAddress;
    bool transactionType = (payee == userAddress) ? true : false;
    BigInt requiredApproval = (decoded[12] as BigInt);
    bool isInvolved = _isInvolvedInTransaction(payee, payers);
    String transactAmount =
        calculateTransactAmount(totalAmount, requiredApproval, transactionType);

    return UserTransaction(
        date: DateTime(year, month, day),
        groupName: groupName,
        transactStatus: transactionStatus,
        transactID: transactionID,
        transactInitiator: transactionInitiator,
        transactPayee: payee.toString(),
        transactPayers: payers,
        transactTitle: transactionTitle,
        totalAmount: totalAmountDecimal,
        category: transactionCategory,
        transactionType: transactionType,
        transactAmount: transactAmount,
        isInvolved: isInvolved);
  }

  bool _isInvolvedInTransaction(
      EthereumAddress payee, List<EthereumAddress> payers) {
    if (payee == userAddress || payers.contains(userAddress)) {
      return true;
    }

    return false;
  }

  String calculateTransactAmount(
      BigInt totalAmount, BigInt payersCount, bool transactionType) {
    BigInt totalMemberCount = (payersCount + BigInt.one);
    BigInt splitAmount = totalAmount ~/ totalMemberCount;
    BigInt payeeAmount = totalAmount - splitAmount;

    String payerAmountDecimal =
        DecimalBigIntConverter.bigIntToDecimal(splitAmount).toStringAsFixed(2);
    String payeeAmountDecimal =
        DecimalBigIntConverter.bigIntToDecimal(payeeAmount).toStringAsFixed(2);

    return transactionType ? payeeAmountDecimal : payerAmountDecimal;
  }

  EventApprovedTransaction decodeEventApprovedTransaction(
      List<dynamic> decoded) {
    int day = (decoded[0] as BigInt).toInt();
    int month = (decoded[1] as BigInt).toInt();
    int year = (decoded[2] as BigInt).toInt();
    String groupName = decoded[3] as String;
    String transactionID = decoded[4].toString();
    EthereumAddress approver = decoded[5] as EthereumAddress;
    return EventApprovedTransaction(
        date: DateTime(year, month, day),
        groupName: groupName,
        transactID: transactionID,
        approver: approver);
  }

  EventDeclinedTransaction decodeEventDeclinedTransaction(
      List<dynamic> decoded) {
    int day = (decoded[0] as BigInt).toInt();
    int month = (decoded[1] as BigInt).toInt();
    int year = (decoded[2] as BigInt).toInt();
    String groupName = decoded[3] as String;
    String transactionID = decoded[4].toString();
    TransactionStatus transactionStatus =
        TransactionStatusExtension.fromInt((decoded[5] as BigInt).toInt());

    return EventDeclinedTransaction(
        date: DateTime(year, month, day),
        groupName: groupName,
        transactID: transactionID,
        transactStatus: transactionStatus);
  }

  EventExecutedTransaction decodeEventExecutedTransaction(
      List<dynamic> decoded) {
    int day = (decoded[0] as BigInt).toInt();
    int month = (decoded[1] as BigInt).toInt();
    int year = (decoded[2] as BigInt).toInt();
    String groupName = decoded[3] as String;
    String transactionID = decoded[4].toString();
    TransactionStatus transactionStatus =
        TransactionStatusExtension.fromInt((decoded[5] as BigInt).toInt());

    return EventExecutedTransaction(
        date: DateTime(year, month, day),
        groupName: groupName,
        transactID: transactionID,
        transactStatus: transactionStatus);
  }
}
