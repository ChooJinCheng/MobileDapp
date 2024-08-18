import 'package:choice/choice.dart';
import 'package:flutter/material.dart';

Widget membersMultiChoiceInput(
    FormFieldState<List<String>> state,
    List<String> selectedMembers,
    Map<String, String> memberAddresses,
    Function(List<String>) setSelectedMembers) {
  return Choice<String>.prompt(
    title: 'Members Address',
    multiple: true,
    confirmation: true,
    value: selectedMembers,
    onChanged: (value) {
      setSelectedMembers(value);
      state.didChange(value);
    },
    itemCount: memberAddresses.length,
    itemBuilder: (state, i) {
      final name = memberAddresses.keys.elementAt(i);
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
      final names = memberAddresses.keys.toList();
      return CheckboxListTile(
        value: state.selectedMany(names),
        onChanged: state.onSelectedMany(names),
        tristate: true,
        title: const Text('Select All'),
      );
    },
    promptDelegate: ChoicePrompt.delegateNewPage(),
  );
}
