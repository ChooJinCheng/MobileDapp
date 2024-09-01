import 'package:dapp/enum/transaction_category_enum.dart';
import 'package:dapp/enum/transaction_status_enum.dart';
import 'package:dapp/model/user_transaction_model.dart';
import 'package:dapp/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:dapp/model/constants/categories_mapping.dart';
import 'package:intl/intl.dart';

Widget transactionListCard(UserTransaction userTransaction) {
  return FutureBuilder<String?>(
      future: _getPayeeName(userTransaction.transactPayee),
      builder: (context, snapshot) {
        String transactPayee = userTransaction.transactPayee;
        String month = DateFormat('MMM').format(userTransaction.date);
        String day = DateFormat('dd').format(userTransaction.date);

        final String transactAmount = _formattedAmount(
            userTransaction.transactAmount,
            userTransaction.transactionType,
            userTransaction.transactStatus,
            userTransaction.isInvolved);
        final Color? statusColor = _statusColor(userTransaction.transactStatus);
        final Color? transactionColor = _transactionColor(
            userTransaction.transactionType,
            userTransaction.transactStatus,
            userTransaction.isInvolved);

        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          transactPayee = snapshot.data!;
        }

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                SizedBox(
                  width: 35,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(month,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500)),
                      Text(day,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500)),
                    ],
                  ),
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
                    categories[userTransaction.category.categoryName],
                    color: Colors.blue,
                    size: 30.0,
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userTransaction.transactTitle,
                          style: const TextStyle(fontSize: 15)),
                      Text(
                          '$transactPayee paid \$${userTransaction.totalAmount}',
                          style: const TextStyle(color: Colors.black54)),
                      Text(userTransaction.transactStatus.statusName,
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
      });
}

String _formattedAmount(
    String amount, bool isCredit, TransactionStatus status, bool isInvolved) {
  if (status == TransactionStatus.declined || !isInvolved) return '--';
  return isCredit ? '+\$$amount' : '-\$$amount';
}

Color? _statusColor(TransactionStatus status) {
  return status == TransactionStatus.declined
      ? Colors.redAccent[700]
      : Colors.green[700];
}

Color? _transactionColor(
    bool isCredit, TransactionStatus status, bool isInvolved) {
  if (status == TransactionStatus.declined || !isInvolved) {
    return Colors.black54;
  }

  return isCredit ? Colors.green[700] : Colors.redAccent[700];
}

Future<String?> _getPayeeName(String address) async {
  String name = await Utils.getContact(address) ?? address;
  return name;
}
