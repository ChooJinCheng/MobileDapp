import 'package:dapp/enum/transaction_category_enum.dart';
import 'package:dapp/enum/transaction_status_enum.dart';
import 'package:dapp/model/constants/categories_mapping.dart';
import 'package:dapp/model/user_transaction_model.dart';
import 'package:dapp/utils/utils.dart';
import 'package:dapp/widgets/empty_message_card.dart';
import 'package:flutter/material.dart';

Widget recentTransactionList(
    List<UserTransaction> userTransactions, double deviceWidth) {
  return Container(
    width: deviceWidth,
    padding: const EdgeInsets.fromLTRB(25, 10, 10, 0),
    margin: const EdgeInsets.only(bottom: 60),
    decoration: const BoxDecoration(
      color: Color.fromRGBO(35, 217, 157, 1.0),
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Your Recent',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'See all',
                style: TextStyle(color: Colors.blue),
              ),
            )
          ],
        ),
        if (userTransactions.isEmpty)
          emptyMessageCard('No transactions available.')
        else
          ...userTransactions.take(3).map((userTransaction) =>
              transactionViewCard(
                  userTransaction.groupName,
                  userTransaction.transactionType,
                  Utils.formatDate(userTransaction.date),
                  userTransaction.transactAmount,
                  userTransaction.category,
                  userTransaction.transactStatus,
                  userTransaction.isInvolved))
      ],
    ),
  );
}

Widget transactionViewCard(
    String groupName,
    bool transactionType,
    String date,
    String amount,
    TransactionCategory category,
    TransactionStatus status,
    bool isInvolved) {
  Color? transactionColor = _transactionColor(transactionType, status);
  String transactAmount =
      _formattedAmount(amount, transactionType, status, isInvolved);
  String transactGroupName =
      _formattedGroupName(groupName, transactionType, status);

  return Container(
    margin: const EdgeInsets.only(bottom: 10.0),
    padding: const EdgeInsets.only(right: 16.0),
    decoration: BoxDecoration(
      color: const Color.fromRGBO(35, 217, 157, 1.0),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            categories[category.categoryName],
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(transactGroupName, style: const TextStyle(fontSize: 16)),
              Text(date, style: const TextStyle(color: Colors.black54)),
            ],
          ),
        ),
        Text(
          transactAmount,
          style: TextStyle(
              color: transactionColor,
              fontSize: 20,
              fontWeight: FontWeight.w600),
        )
      ],
    ),
  );
}

String _formattedAmount(
    String amount, bool isCredit, TransactionStatus status, bool isInvolved) {
  if (status == TransactionStatus.declined || !isInvolved) return '--';
  return isCredit ? '+\$$amount' : '-\$$amount';
}

String _formattedGroupName(
    String groupName, bool isCredit, TransactionStatus status) {
  if (status == TransactionStatus.declined) return '$groupName "Declined"';
  return isCredit ? '$groupName "You get"' : '$groupName "You sent"';
}

Color? _transactionColor(bool isCredit, TransactionStatus status) {
  if (status == TransactionStatus.declined) {
    return Colors.black54;
  }

  return isCredit ? Colors.green[700] : Colors.redAccent[700];
}
