import 'package:flutter/material.dart';

Widget emptyMessageCard(String message) {
  return Center(
    child: Text(
      message,
      style: const TextStyle(fontSize: 16, color: Colors.black54),
    ),
  );
}
