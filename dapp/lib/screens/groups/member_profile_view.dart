import 'package:dapp/utils/contact_utils.dart';
import 'package:flutter/material.dart';

class MemberProfileView extends StatefulWidget {
  const MemberProfileView({super.key, required this.memberAddresses});
  final List<String> memberAddresses;

  @override
  State<MemberProfileView> createState() => _MemberProfileViewState();
}

class _MemberProfileViewState extends State<MemberProfileView> {
  Map<String, String> _membersNameToAddress = {};

  @override
  void initState() {
    super.initState();
    _loadMemberContacts(widget.memberAddresses);
  }

  Future<void> _loadMemberContacts(List<String> memberAddresses) async {
    if (memberAddresses.isEmpty) return;

    Map<String, String> membersContacts = {};

    for (String address in memberAddresses) {
      String name = await ContactUtils.getContact(address) ?? address;
      membersContacts[name] = address;
    }

    setState(() {
      _membersNameToAddress = membersContacts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Members'),
      ),
      body: ListView(
        children: ListTile.divideTiles(context: context, tiles: [
          ListTile(
            leading: Text('Name', style: Theme.of(context).textTheme.bodyLarge),
            title:
                Text('Address', style: Theme.of(context).textTheme.bodyLarge),
          ),
          ..._membersNameToAddress.entries.map((entry) {
            return _buildMemberRow(entry.key, entry.value);
          })
        ]).toList(),
      ),
    );
  }

  Widget _buildMemberRow(String name, String address) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 15.0,
          ),
          Expanded(
            flex: 1,
            child: Text(
              name,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              address,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
