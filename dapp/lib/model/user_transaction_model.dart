import 'package:dapp/enum/transaction_category_enum.dart';
import 'package:dapp/enum/transaction_status_enum.dart';

class UserTransaction {
  String transactID;
  String groupName;
  bool transactionType;
  String date;
  String transactAmount;
  TransactionCategory category;
  String totalAmount;
  String transactTitle;
  String transactInitiator;
  String transactPayee;
  TransactionStatus transactStatus;
//TODO: Make certain fields into ENUM
  UserTransaction(
      {required this.transactID,
      required this.groupName,
      required this.transactionType,
      required this.date,
      required this.transactAmount,
      required this.category,
      required this.totalAmount,
      required this.transactTitle,
      required this.transactInitiator,
      required this.transactPayee,
      required this.transactStatus});
}
