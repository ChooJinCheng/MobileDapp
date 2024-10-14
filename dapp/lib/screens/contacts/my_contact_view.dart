import 'package:dapp/utils/contact_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MyContactView extends StatefulWidget {
  const MyContactView({super.key});

  @override
  State<MyContactView> createState() => _MyContactViewState();
}

class _MyContactViewState extends State<MyContactView> {
  Map<String, String> _contacts = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);
    Map<String, String> contacts =
        await ContactUtils.getContactsAddressToName();
    setState(() {
      _contacts = contacts;
      _isLoading = false;
    });
  }

  Future<void> _deleteContact(String address) async {
    await ContactUtils.deleteContact(address);
    setState(() {
      _contacts.remove(address);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _isLoading ? _buildLoadingIndicator() : _buildContactList(),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'Contacts',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
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
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor:
            AlwaysStoppedAnimation<Color>(Color.fromRGBO(35, 217, 157, 1.0)),
      ),
    );
  }

  Widget _buildContactList() {
    return _contacts.isEmpty
        ? _buildEmptyState()
        : ListView.builder(
            itemCount: _contacts.length,
            itemBuilder: (context, index) {
              final entry = _contacts.entries.elementAt(index);
              return _buildContactCard(entry.key, entry.value);
            },
          );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline,
            size: 80,
            color: Color.fromRGBO(116, 96, 255, 0.5),
          ),
          SizedBox(height: 16),
          Text(
            'No contacts yet',
            style: TextStyle(
              fontSize: 18,
              color: Color.fromRGBO(116, 96, 255, 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(String address, String name) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: const Color.fromRGBO(35, 217, 157, 0.7),
          child: Text(
            name[0].toUpperCase(),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(116, 96, 255, 1.0),
          ),
        ),
        subtitle: Text(
          address,
          style: const TextStyle(fontSize: 12),
          overflow: TextOverflow.visible,
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red.shade400),
          onPressed: () => _showDeleteConfirmation(context, address),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String address) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Contact"),
          content: const Text("Are you sure you want to delete this contact?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
              onPressed: () {
                _deleteContact(address);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
