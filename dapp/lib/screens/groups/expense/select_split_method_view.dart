import 'package:dapp/model/constants/split_methods_mapping.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SelectSplitMethodView extends StatelessWidget {
  const SelectSplitMethodView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Select Split Method'),
        ),
        body: ListView.separated(
          separatorBuilder: (BuildContext context, int index) =>
              const Divider(),
          itemCount: splitMethods.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(splitMethods[index]),
              onTap: () {
                context.pop(splitMethods[index]);
              },
            );
          },
        ));
  }
}
