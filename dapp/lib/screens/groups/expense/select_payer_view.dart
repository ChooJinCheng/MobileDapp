import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SelectPayerView extends StatelessWidget {
  const SelectPayerView({super.key, required this.selectedMembers});

  final List<String> selectedMembers;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Select Payer'),
        ),
        body: ListView.separated(
          separatorBuilder: (BuildContext context, int index) =>
              const Divider(),
          itemCount: selectedMembers.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(selectedMembers[index]),
              onTap: () {
                context.pop(selectedMembers[index]);
              },
            );
          },
        ));
  }
}
