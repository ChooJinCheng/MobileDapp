import 'package:flutter/material.dart';

class ManageTransactionView extends StatefulWidget {
  const ManageTransactionView({super.key});

  @override
  State<ManageTransactionView> createState() => _ManageTransactionViewState();
}

class _ManageTransactionViewState extends State<ManageTransactionView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Manage Transaction',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.sort_rounded),
            tooltip: 'Filter',
            iconSize: 28.0,
          )
        ],
      ),
      body: CustomScrollView(slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Transaction Approval',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 8.0,
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
