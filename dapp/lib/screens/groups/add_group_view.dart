import 'package:dapp/custom_exception/custom_exception.dart';
import 'package:dapp/global_state/providers/group_service_provider.dart';
import 'package:dapp/services/group_service.dart';
import 'package:dapp/utils/contact_utils.dart';
import 'package:dapp/widgets/member_multi_choice_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:validators/validators.dart';
import 'package:web3dart/web3dart.dart';

class AddGroupView extends ConsumerStatefulWidget {
  const AddGroupView({super.key});

  @override
  ConsumerState<AddGroupView> createState() => _AddGroupViewState();
}

class _AddGroupViewState extends ConsumerState<AddGroupView> {
  Map<String, String> _memberNameToAddresses = {};
  List<String> _selectedMembers = [];

  final _groupNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadContactAddresses();
  }

  Future<void> _loadContactAddresses() async {
    Map<String, String> contacts =
        await ContactUtils.getContactsNameToAddress();

    setState(() {
      _memberNameToAddresses = contacts;
    });
  }

  void _setSelectedMembers(List<String> value) {
    setState(() => _selectedMembers = value);
  }

  String? _validateGroupName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your group name';
    } else if (!isAlphanumeric(value)) {
      return 'Please enter only alphanumeric characters';
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
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _addNewGroup(groupService);
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
                      membersMultiChoiceInput(state, _selectedMembers,
                          _memberNameToAddresses, _setSelectedMembers),
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

  Future<void> _addNewGroup(GroupService groupService) async {
    try {
      List<dynamic> args = [];
      String groupName = _groupNameController.text;
      List<EthereumAddress> members = _selectedMembers
          .map((name) => EthereumAddress.fromHex(_memberNameToAddresses[name]!))
          .toList();
      if (!_selectedMembers.contains(groupService.userAddress.toString())) {
        members.add(groupService.userAddress);
      }
      args.add(groupName);
      args.add(members);

      await groupService.addNewGroup(args);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group Added Successfully')),
      );

      context.pop();
    } on RpcException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Transaction failed: ${e.message}'),
      ));
    } on GeneralException catch (e) {
      if (!mounted) return;
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('An unexpected error occurred. Please try again.'),
      ));
    } catch (e) {
      if (!mounted) return;
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('An error occurred.'),
      ));
    }
  }
}
