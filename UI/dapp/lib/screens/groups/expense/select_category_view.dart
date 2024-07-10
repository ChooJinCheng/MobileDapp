import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SelectCategoryView extends StatelessWidget {
  const SelectCategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Category'),
      ),
      body: ListView(
          children: ListTile.divideTiles(context: context, tiles: [
        ListTile(
          leading: const Icon(Icons.local_dining),
          title: const Text('food'),
          onTap: () {
            context.pop('food');
          },
        ),
        ListTile(
          leading: const Icon(Icons.attractions),
          title: const Text('activity'),
          onTap: () {
            context.pop('activity');
          },
        ),
        ListTile(
          leading: const Icon(Icons.commute),
          title: const Text('transport'),
          onTap: () {
            context.pop('transport');
          },
        ),
        ListTile(
          leading: const Icon(Icons.miscellaneous_services),
          title: const Text('services'),
          onTap: () {
            context.pop('services');
          },
        ),
        ListTile(
          leading: const Icon(Icons.checkroom),
          title: const Text('apparel'),
          onTap: () {
            context.pop('apparel');
          },
        ),
      ]).toList()),
    );
  }
}
