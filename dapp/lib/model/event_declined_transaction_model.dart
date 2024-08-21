import 'package:dapp/enum/transaction_status_enum.dart';

class EventDeclinedTransaction {
  String groupName;
  DateTime date;
  String transactID;
  TransactionStatus transactStatus;

  EventDeclinedTransaction({
    required this.groupName,
    required this.date,
    required this.transactID,
    required this.transactStatus,
  });
}
