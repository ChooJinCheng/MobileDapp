import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    Map<String, String> contacts = {};
    for (String key in keys) {
      contacts[key] = prefs.getString(key)!;
    }
    setState(() {
      _contacts = contacts;
    });
  }

  Future<void> _deleteContact(String address) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(address);
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
                  style: Theme.of(context).textTheme.bodyLarge), // Contact name
              title: Text(entry.key,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge), // Ethereum address
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
