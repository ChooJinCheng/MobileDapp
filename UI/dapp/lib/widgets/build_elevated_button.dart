import 'package:flutter/material.dart';

Widget buildElevatedButton(String title, IconData icon) {
  return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.5),
          shadowColor: Colors.transparent),
      child: Wrap(
        children: <Widget>[
          Icon(
            icon,
            color: const Color.fromRGBO(116, 96, 255, 1.0),
            size: 17.0,
          ),
          Text(title,
              style: const TextStyle(color: Color.fromRGBO(116, 96, 255, 1.0))),
        ],
      ));
}
