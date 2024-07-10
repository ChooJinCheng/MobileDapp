import 'package:dapp/model/group_profile_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Widget groupListCard(GroupProfile groupProfile, BuildContext context) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 6.0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0),
    ),
    child: InkWell(
      customBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      onTap: () {
        context.goNamed('groupProfile',
            pathParameters: {'groupID': groupProfile.groupID.toString()});
      },
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 35,
              backgroundImage: AssetImage(groupProfile.groupImagePath),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    groupProfile.groupName,
                    style: const TextStyle(
                        fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  Text('${groupProfile.membersCount} Members'),
                  Text('Balance: ${groupProfile.deposit}',
                      style:
                          const TextStyle(color: Colors.teal, fontSize: 18.0)),
                  Text(
                      'Latest transaction: ${groupProfile.latestTransactionDate}'),
                ],
              ),
            ),
            PopupMenuButton<String>(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(14.0))),
              onSelected: (String value) {
                // Handle menu item selection
              },
              itemBuilder: (BuildContext context) {
                return {'Deposit', 'Withdraw', 'Disband'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Center(child: Text(choice)),
                  );
                }).toList();
              },
            ),
          ],
        ),
      ),
    ),
  );
}
