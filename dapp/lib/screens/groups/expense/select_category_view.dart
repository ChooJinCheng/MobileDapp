import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dapp/model/constants/categories_mapping.dart';
import 'package:dapp/enum/transaction_category_enum.dart';

class SelectCategoryView extends StatelessWidget {
  const SelectCategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Category'),
      ),
      body: ListView(
        children: ListTile.divideTiles(
          context: context,
          tiles: TransactionCategory.values.map((category) {
            final String categoryName = category.categoryName;
            return ListTile(
              leading: Icon(categories[categoryName]),
              title: Text(categoryName),
              onTap: () {
                context.pop(category);
              },
            );
          }),
        ).toList(),
      ),
    );
  }
}
