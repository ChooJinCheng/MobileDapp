import 'package:dapp/enum/transaction_category_enum.dart';
import 'package:dapp/model/user_transaction_model.dart';
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
                  userTransaction.date.toString(),
                  userTransaction.transactAmount,
                  userTransaction.category))
      ],
    ),
  );
}

//Need to synchronize with created enums and mappings
Widget transactionViewCard(String groupName, bool transactionType, String date,
    String transactAmount, TransactionCategory category) {
  Map<String, IconData> categories = {
    'food': Icons.local_dining,
    'activity': Icons.attractions,
    'transport': Icons.commute,
    'services': Icons.miscellaneous_services,
    'apparel': Icons.checkroom
  };
  Color? transactionColor = Colors.green[700];
  if (transactionType) {
    transactAmount = '+\$$transactAmount';
    groupName = '$groupName "You get"';
  } else {
    transactAmount = '-\$$transactAmount';
    groupName = '$groupName "You sent"';
    transactionColor = Colors.redAccent[700];
  }

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
              Text(groupName, style: const TextStyle(fontSize: 16)),
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
