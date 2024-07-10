import 'package:flutter/material.dart';
import 'package:dapp/widgets/build_elevated_button.dart';

Widget groupProfileCard() {
  return Container(
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(
      color: const Color.fromRGBO(35, 217, 157, 0.7),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const CircleAvatar(
          radius: 35,
          backgroundColor: Colors.black,
        ),
        const Text(
          'Balance: \$43.26',
          style: TextStyle(
              fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const Text(
          'Pending Transactions: 2',
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Color.fromRGBO(124, 124, 124, 1.0)),
        ),
        const Text(
          '3 Members',
          style: TextStyle(
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
            buildElevatedButton('Deposit', Icons.call_made),
            buildElevatedButton('Withdraw', Icons.call_received),
            buildElevatedButton('Members', Icons.group),
          ],
        ),
      ],
    ),
  );
}
