import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyPortfolio(),
    );
  }
}

class MyPortfolio extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Icon(Icons.notifications, color: Colors.black),
        actions: [
          Icon(Icons.settings, color: Colors.black),
          SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Portfolio',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildBalanceCard(),
            SizedBox(height: 16),
            Text(
              'You are in 3 groups',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            _buildGroups(),
            SizedBox(height: 16),
            _buildRecentTransactions(),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFA7F3D0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Balance',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          Text(
            '420.13 SGD',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          Text(
            'In wallet: 100 SGD',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton('Deposit', Icons.call_made),
              _buildActionButton('Withdraw', Icons.call_received),
              _buildActionButton('Send', Icons.send),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue),
        SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(color: Colors.blue),
        ),
      ],
    );
  }

  Widget _buildGroups() {
    return Container(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildGroupCard('Group 1', '120.13 SGD', Colors.orange),
          _buildGroupCard('Group 2', '89.25 SGD', Colors.green),
          _buildGroupCard('Group 3', '230.00 SGD', Colors.blue),
        ],
      ),
    );
  }

  Widget _buildGroupCard(String groupName, String balance, Color color) {
    return Container(
      width: 200,
      margin: EdgeInsets.only(right: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            groupName,
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
          SizedBox(height: 8),
          Text(
            'Deposit Balance:',
            style: TextStyle(fontSize: 12, color: Colors.white70),
          ),
          Text(
            balance,
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Recent',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'See all',
              style: TextStyle(color: Colors.blue),
            ),
          ],
        ),
        SizedBox(height: 8),
        _buildTransactionItem(
            'Group 2 "You spent"', '- \$54', '13 August, 10:00AM', Colors.red),
        _buildTransactionItem('Group 1 "You received"', '+ \$23',
            '12 August, 11:00AM', Colors.green),
      ],
    );
  }

  Widget _buildTransactionItem(
      String title, String amount, String date, Color amountColor) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFA7F3D0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.square, color: Colors.blue),
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 16)),
              Text(date, style: TextStyle(color: Colors.black54)),
            ],
          ),
          Spacer(),
          Text(
            amount,
            style: TextStyle(color: amountColor, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
