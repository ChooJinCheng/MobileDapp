import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

Widget transactionSlidable() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Slidable(
        endActionPane: ActionPane(
          motion: const BehindMotion(),
          children: [
            SlidableAction(
              onPressed: (context) {},
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.close,
              borderRadius: BorderRadius.circular(16.0),
            ),
            SlidableAction(
              onPressed: (context) {},
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
                        'John',
                        style: const TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                      Text('John initiated to get \$25 from you for "Putien"'),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '30 May 2024',
                      style: const TextStyle(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w400,
                          color: Color.fromRGBO(124, 124, 124, 1.0)),
                    ),
                    SizedBox(height: 5.0),
                    Text(
                      '-\$25',
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
}
