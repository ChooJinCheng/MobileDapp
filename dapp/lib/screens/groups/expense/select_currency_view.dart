import 'package:dapp/model/constants/currencies_mapping.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SelectCurrencyView extends StatelessWidget {
  const SelectCurrencyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Select Currency'),
        ),
        body: ListView.separated(
          separatorBuilder: (BuildContext context, int index) =>
              const Divider(),
          itemCount: currencyCodes.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(countryNames[index]),
              onTap: () {
                context.pop(currencyCodes[index]);
              },
            );
          },
        ));
  }
}
