import 'package:dapp/model/group_profile_model.dart';
import 'package:flutter/material.dart';
import 'package:dapp/widgets/build_elevated_button.dart';
import 'package:go_router/go_router.dart';

Widget groupProfileCard(GroupProfile groupProfile,
    String pendingTransactionCount, BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(
      color: const Color.fromRGBO(35, 217, 157, 0.7),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 35,
          backgroundImage: AssetImage(groupProfile.groupImagePath),
          backgroundColor: Colors.white,
        ),
        Text(
          'Balance: \$${groupProfile.deposit}',
          style: const TextStyle(
              fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text(
          'Pending Transactions: $pendingTransactionCount',
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Color.fromRGBO(124, 124, 124, 1.0)),
        ),
        Text(
          '${groupProfile.membersCount} Members',
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Color.fromRGBO(124, 124, 124, 1.0)),
        ),
        const Divider(
          color: Color.fromRGBO(124, 124, 124, 1.0),
          thickness: 0.2,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            buildElevatedButton('Deposit', Icons.call_made, (context) {
              context.pushNamed<void>('depositGroup', extra: groupProfile);
            }),
            buildElevatedButton('Withdraw', Icons.call_received, (context) {
              context.pushNamed<void>('withdrawGroup', extra: groupProfile);
            }),
            buildElevatedButton('Members', Icons.group, (context) {
              context.pushNamed<void>('members',
                  extra: groupProfile.memberAddresses);
            }),
          ],
        ),
      ],
    ),
  );
}
