import 'package:dapp/enum/transaction_status_enum.dart';

class EventExecutedTransaction {
  DateTime date;
  String groupName;
  String transactID;
  TransactionStatus transactStatus;

  EventExecutedTransaction({
    required this.date,
    required this.groupName,
    required this.transactID,
    required this.transactStatus,
  });
}
