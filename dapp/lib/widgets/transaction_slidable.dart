import 'package:dapp/custom_exception/custom_exception.dart';
import 'package:dapp/global_state/providers/transaction_service_provider.dart';
import 'package:dapp/model/user_transaction_model.dart';
import 'package:dapp/services/transaction_service.dart';
import 'package:dapp/utils/contact_utils.dart';
import 'package:dapp/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

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
          String date = Utils.formatDate(userTransaction.date);
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
                        _declineTransasction(transactionService, context);
                      },
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      icon: Icons.close,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    SlidableAction(
                      onPressed: (context) {
                        _approveTransaction(transactionService, context);
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

  void _declineTransasction(
      TransactionService transactionService, BuildContext context) async {
    try {
      List<dynamic> args = [
        userTransaction.groupName,
        BigInt.from(int.parse(userTransaction.transactID))
      ];

      await transactionService.declineTransaction(groupContractAddress, args);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Transaction Declined'),
      ));
    } on RpcException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Transaction failed: ${e.message}'),
      ));
    } on GeneralException catch (e) {
      if (!context.mounted) return;
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('An unexpected error occurred. Please try again.'),
      ));
    } catch (e) {
      if (!context.mounted) return;
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('An error occurred.'),
      ));
    }
  }

  void _approveTransaction(
      TransactionService transactionService, BuildContext context) async {
    try {
      List<dynamic> args = [
        userTransaction.groupName,
        BigInt.from(int.parse(userTransaction.transactID))
      ];
      await transactionService.approveTransaction(groupContractAddress, args);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Transaction Approved'),
      ));
    } on RpcException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Transaction failed: ${e.message}'),
      ));
    } on GeneralException catch (e) {
      if (!context.mounted) return;
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('An unexpected error occurred. Please try again.'),
      ));
    } catch (e) {
      if (!context.mounted) return;
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('An error occurred.'),
      ));
    }
  }
}

Future<String?> _getInitiatorName(String address) async {
  String name = await ContactUtils.getContact(address) ?? address;
  return name;
}
