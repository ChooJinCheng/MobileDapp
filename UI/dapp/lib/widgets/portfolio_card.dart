import 'package:flutter/material.dart';
import 'package:dapp/widgets/build_elevated_button.dart';

Widget portfolioCard() {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color.fromRGBO(35, 217, 157, 0.7),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Total Balance',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Color.fromRGBO(124, 124, 124, 1.0)),
        ),
        const Text(
          '420.13 SGD',
          style: TextStyle(
              fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const Text(
          'In wallet: 100 SGD',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
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
            buildElevatedButton('Send', Icons.send),
          ],
        ),
      ],
    ),
  );
}
