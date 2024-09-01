import 'package:dapp/enum/transaction_category_enum.dart';
import 'package:dapp/enum/transaction_status_enum.dart';
import 'package:web3dart/web3dart.dart';

class UserTransaction {
  DateTime date;
  String groupName;
  TransactionStatus transactStatus;
  String transactID;
  String transactInitiator;
  String transactPayee;
  List<EthereumAddress> transactPayers;
  String transactTitle;
  String totalAmount;
  TransactionCategory category;
  bool transactionType;
  String transactAmount;
  bool isInvolved;

//TODO: Make certain fields into ENUM
  UserTransaction({
    required this.date,
    required this.groupName,
    required this.transactStatus,
    required this.transactID,
    required this.transactInitiator,
    required this.transactPayee,
    required this.transactPayers,
    required this.transactTitle,
    required this.totalAmount,
    required this.category,
    required this.transactionType,
    required this.transactAmount,
    required this.isInvolved,
  });
}
