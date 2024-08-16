import 'package:flutter/material.dart';

class AddExpenseScreen extends StatelessWidget {
  const AddExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Add expense', style: TextStyle(color: Colors.black)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'People Involved:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.group, color: Colors.purple),
              label: const Text(
                'All members',
                style: TextStyle(color: Colors.purple),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Colors.purple),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'Group 1',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              decoration: InputDecoration(
                hintText: 'Enter a description',
                suffixIcon:
                    const Icon(Icons.receipt_long, color: Colors.purple),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: '0.00',
                prefixText: '',
                suffixText: 'USD',
                suffixStyle: const TextStyle(color: Colors.purple),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                _buildChip('Paid by', 'You'),
                _buildChip('and split', 'Equally'),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                _buildChip('When', 'Now'),
                _buildChip('Rates', 'Market'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Chip(
          label: Text(
            label,
            style: TextStyle(color: Colors.grey[600]),
          ),
          backgroundColor: Colors.grey[200],
        ),
        const SizedBox(width: 4),
        Chip(
          label: Text(
            value,
            style: const TextStyle(color: Colors.purple),
          ),
          backgroundColor: Colors.purple[50],
        ),
      ],
    );
  }
}

void main() {
  runApp(const MaterialApp(home: AddExpenseScreen()));
}
