import 'package:flutter/material.dart';

Widget groupCarouselCard(
    String groupName, String deposit, String groupImagePath) {
  return Container(
    width: 200,
    padding: const EdgeInsets.only(top: 20.0),
    decoration: BoxDecoration(
      color: const Color.fromRGBO(245, 168, 78, 1.0),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          groupName,
          style: const TextStyle(fontSize: 20.0, color: Colors.white),
        ),
        const SizedBox(height: 8.0),
        CircleAvatar(
          backgroundImage: AssetImage(groupImagePath),
          radius: 30.0,
          backgroundColor: Colors.white,
        ),
        const SizedBox(
          height: 8.0,
        ),
        const Text(
          'Deposit Balance: ',
          style: TextStyle(fontSize: 14.0, color: Colors.white),
        ),
        Text(
          '\$$deposit',
          style: const TextStyle(
              fontSize: 28.0, color: Colors.black, fontWeight: FontWeight.w500),
        ),
        const SizedBox(
          height: 8.0,
        ),
      ],
    ),
  );
}
