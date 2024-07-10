import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GroupDetailScreen(),
    );
  }
}

class GroupDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Group 1'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Handle back button press
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.black,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Balance: \$43.26',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Pending Transactions: 2',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    Text(
                      '3 Members',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.account_balance_wallet),
                          label: Text('Deposit'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.money_off),
                          label: Text('Withdraw'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.group),
                          label: Text('Members'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Pending Transactions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.black,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Me'),
                          Text('Transaction pending for others approval',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                    Text(
                      '+ \$46',
                      style: TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: Icon(Icons.check, color: Colors.green),
                      onPressed: () {
                        // Handle approve
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        // Handle reject
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Transactions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'March 2024',
                    style: TextStyle(color: Colors.grey),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text('All'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
              TransactionListItem(
                date: 'Mar 21',
                description: 'Dhoby to Bugis GRAB',
                name: 'John paid \$9',
                amount: '- \$3',
                status: 'Approved',
                color: Colors.red,
              ),
              TransactionListItem(
                date: 'Mar 20',
                description: 'Hotel Accommodation',
                name: 'Mary paid \$128',
                amount: '- \$42.66',
                status: 'Approved',
                color: Colors.red,
              ),
              TransactionListItem(
                date: 'Mar 20',
                description: 'Koi The',
                name: 'You paid \$21',
                amount: '+ \$14',
                status: 'Approved',
                color: Colors.green,
              ),
              TransactionListItem(
                date: 'Mar 18',
                description: 'Hotel Add Ons',
                name: 'John paid \$28',
                amount: '- \$8',
                status: 'Declined',
                color: Colors.red,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Handle add expense
        },
        icon: Icon(Icons.add),
        label: Text('Add Expense'),
      ),
    );
  }
}

class TransactionListItem extends StatelessWidget {
  final String date;
  final String description;
  final String name;
  final String amount;
  final String status;
  final Color color;

  const TransactionListItem({
    required this.date,
    required this.description,
    required this.name,
    required this.amount,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            date.split(' ')[0],
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            date.split(' ')[1],
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      title: Text(description),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name),
          Text(
            status,
            style: TextStyle(color: Colors.green),
          ),
        ],
      ),
      trailing: Text(
        amount,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
