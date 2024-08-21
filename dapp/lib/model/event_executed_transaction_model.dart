import 'package:dapp/enum/transaction_status_enum.dart';

class EventExecutedTransaction {
  String groupName;
  DateTime date;
  String transactID;
  TransactionStatus transactStatus;

  EventExecutedTransaction({
    required this.groupName,
    required this.date,
    required this.transactID,
    required this.transactStatus,
  });
}
