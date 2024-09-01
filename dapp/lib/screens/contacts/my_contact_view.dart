import 'package:dapp/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MyContactView extends StatefulWidget {
  const MyContactView({super.key});

  @override
  State<MyContactView> createState() => _MyContactViewState();
}

class _MyContactViewState extends State<MyContactView> {
  Map<String, String> _contacts = {};

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    Map<String, String> contacts = await Utils.getContactsAddressToName();
    setState(() {
      _contacts = contacts;
    });
  }

  Future<void> _deleteContact(String address) async {
    await Utils.deleteContact(address);
    setState(() {
      _contacts.remove(address);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Contacts'),
        actions: [
          IconButton(
            onPressed: () {
              context.pushNamed('addContact').then((_) {
                _loadContacts();
              });
            },
            icon: const Icon(Icons.person_add),
            tooltip: 'Add Contacts',
            iconSize: 28.0,
          )
        ],
      ),
      body: ListView(
        children: ListTile.divideTiles(context: context, tiles: [
          ListTile(
            leading: Text('Name', style: Theme.of(context).textTheme.bodyLarge),
            title:
                Text('Address', style: Theme.of(context).textTheme.bodyLarge),
          ),
          ..._contacts.entries.map((entry) {
            return ListTile(
              leading: Text(entry.value,
                  style: Theme.of(context).textTheme.bodyLarge),
              title:
                  Text(entry.key, style: Theme.of(context).textTheme.bodyLarge),
              trailing: IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Colors.red.shade900,
                ),
                onPressed: () {
                  _deleteContact(entry.key);
                },
              ),
            );
          })
        ]).toList(),
      ),
    );
  }
}
