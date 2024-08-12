import 'package:dapp/providers/group_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:choice/choice.dart';
import 'package:go_router/go_router.dart';
import 'package:web3dart/web3dart.dart';

class AddGroupView extends ConsumerStatefulWidget {
  const AddGroupView({super.key});

  @override
  ConsumerState<AddGroupView> createState() => _AddGroupViewState();
}

class _AddGroupViewState extends ConsumerState<AddGroupView> {
  List<String> memberAddresses = [
    '0x785D13806600B9c60FfD832Dbe553678893283D9',
    '0xB83e465268147456070a302dBC1d06080011876b',
    '0x8a4c7a15B52A077d1394D868588b7F88Fc93C853',
  ];
  List<String> selectedAddresses = [];

  final groupNameFieldController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  void setSelectedAddresses(List<String> value) {
    setState(() => selectedAddresses = value);
  }

  @override
  void dispose() {
    groupNameFieldController.dispose();
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
              if (formKey.currentState!.validate()) {
                List<dynamic> args = [];
                String groupName = groupNameFieldController.text;
                List<EthereumAddress> selectedEthAddresses = selectedAddresses
                    .map((address) => EthereumAddress.fromHex(address))
                    .toList();
                args.add(groupName);
                args.add(selectedEthAddresses);
                try {
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
        key: formKey,
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
                      controller: groupNameFieldController,
                      decoration: const InputDecoration(
                        labelText: 'Group Name',
                      ),
                      // The validator receives the text that the user has entered.
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your group name';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              FormField<List<String>>(
                initialValue: selectedAddresses,
                validator: (value) {
                  if (value == null || value.length < 2) {
                    return 'Please select at least 2 choices';
                  }
                  return null;
                },
                builder: (FormFieldState<List<String>> state) {
                  return Column(
                    children: [
                      Choice<String>.prompt(
                        title: 'Members Address',
                        multiple: true,
                        confirmation: true,
                        value: selectedAddresses,
                        onChanged: (value) {
                          setSelectedAddresses(value);
                          state.didChange(value);
                        },
                        itemCount: memberAddresses.length,
                        itemBuilder: (state, i) {
                          return CheckboxListTile(
                            value: state.selected(memberAddresses[i]),
                            onChanged: state.onSelected(memberAddresses[i]),
                            title: ChoiceText(
                              memberAddresses[i],
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
                          return CheckboxListTile(
                            value: state.selectedMany(memberAddresses),
                            onChanged: state.onSelectedMany(memberAddresses),
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
