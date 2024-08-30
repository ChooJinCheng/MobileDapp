import 'package:dapp/global_state/providers/transaction_service_provider.dart';
import 'package:dapp/model/user_transaction_model.dart';
import 'package:dapp/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class TransactionSlidable extends ConsumerWidget {
  final UserTransaction userTransaction;
  final String groupContractAddress;

  const TransactionSlidable(
      {super.key,
      required this.userTransaction,
      required this.groupContractAddress});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<String?>(
        future: _getInitiatorName(userTransaction.transactInitiator),
        builder: (context, snapshot) {
          final transactionService = ref.watch(transactionServiceProvider);
          String date = DateFormat('dd MMM yyyy').format(userTransaction.date);
          String transactInitiator = userTransaction.transactInitiator;
          String transactAmount = userTransaction.transactAmount;

          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            transactInitiator = snapshot.data!;
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Slidable(
                endActionPane: ActionPane(
                  motion: const BehindMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) {
                        try {
                          List<dynamic> args = [
                            userTransaction.groupName,
                            BigInt.from(int.parse(userTransaction.transactID))
                          ];

                          transactionService.declineTransaction(
                              groupContractAddress, args);
                        } catch (e) {
                          print('Error: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Error encountered. Please try again')));
                        }
                      },
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      icon: Icons.close,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    SlidableAction(
                      onPressed: (context) {
                        try {
                          List<dynamic> args = [
                            userTransaction.groupName,
                            BigInt.from(int.parse(userTransaction.transactID))
                          ];
                          transactionService.approveTransaction(
                              groupContractAddress, args);
                        } catch (e) {
                          print('Error: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Error encountered. Please try again')));
                        }
                      },
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      icon: Icons.done,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                  ],
                ),
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 0.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.black,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                transactInitiator,
                                style: const TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                  '$transactInitiator initiated to get \$$transactAmount from you for "${userTransaction.transactTitle}"'),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              date,
                              style: const TextStyle(
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w400,
                                  color: Color.fromRGBO(124, 124, 124, 1.0)),
                            ),
                            const SizedBox(height: 5.0),
                            Text(
                              '-\$$transactAmount',
                              style: TextStyle(
                                  color: Colors.redAccent[700],
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                )),
          );
        });
  }
}

Future<String?> _getInitiatorName(String address) async {
  String name = await Utils.getContact(address) ?? address;
  return name;
}
