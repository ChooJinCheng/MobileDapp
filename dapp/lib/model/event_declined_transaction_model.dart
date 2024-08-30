import 'package:dapp/enum/transaction_status_enum.dart';

class EventDeclinedTransaction {
  DateTime date;
  String groupName;
  String transactID;
  TransactionStatus transactStatus;

  EventDeclinedTransaction({
    required this.date,
    required this.groupName,
    required this.transactID,
    required this.transactStatus,
  });
}
