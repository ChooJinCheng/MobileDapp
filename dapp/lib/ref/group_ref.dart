import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GroupsScreen(),
    );
  }
}

class Group {
  final String name;
  final int members;
  final String balance;
  final String latestTransactionDate;
  final String imagePath;

  Group({
    required this.name,
    required this.members,
    required this.balance,
    required this.latestTransactionDate,
    required this.imagePath,
  });
}

class GroupsScreen extends StatelessWidget {
  final List<Group> groups = [
    Group(
      name: 'Group 1',
      members: 3,
      balance: '\$43.26',
      latestTransactionDate: '28 May 2024',
      imagePath: 'assets/group1.png',
    ),
    Group(
      name: 'Group 2',
      members: 5,
      balance: '\$23.14',
      latestTransactionDate: '30 May 2024',
      imagePath: 'assets/group2.png',
    ),
    Group(
      name: 'Group 3',
      members: 2,
      balance: '\$25.00',
      latestTransactionDate: '22 May 2024',
      imagePath: 'assets/group3.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Groups'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () {
                // Add new group action
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF00C853), // Button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: Colors.white),
                  SizedBox(width: 8),
                  Text('New Group', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  return GroupCard(group: groups[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GroupCard extends StatelessWidget {
  final Group group;

  GroupCard({required this.group});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage(group.imagePath),
            ),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.name,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text('${group.members} Members'),
                Text('Balance: ${group.balance}',
                    style: TextStyle(color: Colors.teal, fontSize: 16)),
                Text('Latest transaction date: ${group.latestTransactionDate}'),
              ],
            ),
            Spacer(),
            PopupMenuButton<String>(
              onSelected: (String value) {
                // Handle menu item selection
              },
              itemBuilder: (BuildContext context) {
                return {'Deposit', 'Withdraw', 'Disband'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ],
        ),
      ),
    );
  }
}
