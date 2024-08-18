import 'package:dapp/enum/transaction_category_enum.dart';
import 'package:dapp/enum/transaction_status_enum.dart';
import 'package:dapp/model/user_transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:dapp/model/constants/categories_mapping.dart';

Widget transactionListCard(UserTransaction userTransaction) {
  String transactAmount = userTransaction.transactAmount;
  String totalAmount = userTransaction.totalAmount;
  String transactTitle = userTransaction.transactTitle;
  TransactionCategory category = userTransaction.category;
  String transactPayee = userTransaction.transactPayee;
  TransactionStatus transactStatus = userTransaction.transactStatus;
  bool transactionType = userTransaction.transactionType;

  Color? statusColor = Colors.green[700];
  Color? transactionColor = Colors.green[700];
  if (transactStatus == TransactionStatus.declined) {
    statusColor = Colors.redAccent[700];
    transactionColor = Colors.black54;
    transactAmount = '--';
  } else {
    if (transactionType) {
      transactAmount = '+\$$transactAmount';
    } else {
      transactAmount = '-\$$transactAmount';
      transactionColor = Colors.redAccent[700];
    }
  }

  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('May',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              Text('21',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(
            width: 8.0,
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              categories[category.categoryName],
              color: Colors.blue,
              size: 30.0,
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transactTitle, style: const TextStyle(fontSize: 15)),
                Text('$transactPayee paid \$$totalAmount',
                    style: const TextStyle(color: Colors.black54)),
                Text(transactStatus.statusName,
                    style: TextStyle(fontSize: 14, color: statusColor)),
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
    ),
  );
}
