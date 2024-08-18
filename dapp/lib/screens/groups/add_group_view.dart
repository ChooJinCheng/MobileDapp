import 'package:dapp/global_state/providers/group_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:choice/choice.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3dart/web3dart.dart';

class AddGroupView extends ConsumerStatefulWidget {
  const AddGroupView({super.key});

  @override
  ConsumerState<AddGroupView> createState() => _AddGroupViewState();
}

class _AddGroupViewState extends ConsumerState<AddGroupView> {
  Map<String, String> _memberAddresses = {};
  List<String> _selectedMembers = [];

  final _groupNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadContactAddresses();
  }

  Future<void> _loadContactAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    Map<String, String> contacts = {};
    for (String key in keys) {
      contacts[prefs.getString(key)!] = key;
    }
    setState(() {
      _memberAddresses = contacts;
    });
  }

  void _setSelectedMembers(List<String> value) {
    setState(() => _selectedMembers = value);
  }

  String? _validateGroupName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your group name';
    }
    return null;
  }

  String? _validateSelectedAddresses(List<String>? value) {
    if (value == null || value.isEmpty) {
      return 'Please select at least 1 member';
    }
    return null;
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupService = ref.watch(groupServiceProvider);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        scrolledUnderElevation: 0.0,
        backgroundColor: Colors.white,
        title: const Text(
          'Add Group',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                try {
                  List<dynamic> args = [];
                  String groupName = _groupNameController.text;
                  List<EthereumAddress> members = _selectedMembers
                      .map((name) =>
                          EthereumAddress.fromHex(_memberAddresses[name]!))
                      .toList();
                  members.add(groupService.userAddress);
                  args.add(groupName);
                  args.add(members);
                  groupService.addNewGroup(args);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Group Added Successfully')),
                  );
                  context.pop();
                } catch (e) {
                  print('Error: $e');
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Error encountered. Please try again')));
                }
              }
            },
            icon: const Icon(Icons.group_add_sharp),
            tooltip: 'Add group',
            iconSize: 28.0,
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.black,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                        controller: _groupNameController,
                        decoration: const InputDecoration(
                          labelText: 'Group Name',
                        ),
                        // The validator receives the text that the user has entered.
                        validator: _validateGroupName),
                  ),
                ],
              ),
              FormField<List<String>>(
                initialValue: _selectedMembers,
                validator: _validateSelectedAddresses,
                builder: (FormFieldState<List<String>> state) {
                  return Column(
                    children: [
                      Choice<String>.prompt(
                        title: 'Members Address',
                        multiple: true,
                        confirmation: true,
                        value: _selectedMembers,
                        onChanged: (value) {
                          _setSelectedMembers(value);
                          state.didChange(value);
                        },
                        itemCount: _memberAddresses.length,
                        itemBuilder: (state, i) {
                          final name = _memberAddresses.keys.elementAt(i);
                          return CheckboxListTile(
                            value: state.selected(name),
                            onChanged: state.onSelected(name),
                            title: ChoiceText(
                              name,
                              highlight: state.search?.value,
                            ),
                          );
                        },
                        modalHeaderBuilder: ChoiceModal.createHeader(
                          automaticallyImplyLeading: false,
                          actionsBuilder: [
                            ChoiceModal.createConfirmButton(),
                            ChoiceModal.createSpacer(width: 10),
                          ],
                        ),
                        modalSeparatorBuilder: (state) {
                          final names = _memberAddresses.keys.toList();
                          return CheckboxListTile(
                            value: state.selectedMany(names),
                            onChanged: state.onSelectedMany(names),
                            tristate: true,
                            title: const Text('Select All'),
                          );
                        },
                        promptDelegate: ChoicePrompt.delegateNewPage(),
                      ),
                      if (state.hasError)
                        Text(
                          state.errorText ?? '',
                          style: TextStyle(color: Colors.red.shade900),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
