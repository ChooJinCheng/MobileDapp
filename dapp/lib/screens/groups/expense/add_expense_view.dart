import 'package:choice/choice.dart';
import 'package:dapp/enum/transaction_category_enum.dart';
import 'package:dapp/model/constants/categories_mapping.dart';
import 'package:dapp/model/group_profile_model.dart';
import 'package:dapp/widgets/member_multi_choice_input.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddExpenseView extends StatefulWidget {
  final GroupProfile groupProfile;
  const AddExpenseView({super.key, required this.groupProfile});

  @override
  State<AddExpenseView> createState() => _AddExpenseViewState();
}

class _AddExpenseViewState extends State<AddExpenseView> {
  Map<String, String> _memberNameToAddresses = {};
  List<String> _selectedMembers = [];

  TransactionCategory selectedCategory = TransactionCategory.food;
  String _selectedCurrency = 'USD';
  String _selectedPayer = 'You';
  String _selectedSplitMethod = 'Equally';
  String _selectedDateTime = 'Now';
  String _selectedRateMethod = 'Market';

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _loadContactAddresses();
    super.initState();
  }

  Future<void> _loadContactAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, String> contacts = {};
    List<String> memberAddresses = widget.groupProfile.memberAddresses;
    Set<String> keys = prefs.getKeys();
    print('keys: $keys');
    for (String memberAddress in memberAddresses) {
      print('Name: ${prefs.getString(memberAddress)} and addr: $memberAddress');
      String name = (prefs.getString(memberAddress)) ?? memberAddress;
      contacts[name] = memberAddress;
    }
    print('mem value $contacts');
    setState(() {
      _memberNameToAddresses = contacts;
    });
  }

  void _setSelectedMembers(List<String> value) {
    setState(() => _selectedMembers = value);
  }

  String? _validateSelectedAddresses(List<String>? value) {
    if (value == null || value.isEmpty) {
      return 'Please select at least 1 member';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final GroupProfile groupProfile = widget.groupProfile;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        scrolledUnderElevation: 0.0,
        backgroundColor: Colors.white,
        title: const Text(
          'Add Expense',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add_box_rounded),
            tooltip: 'Add Expense',
            iconSize: 28.0,
          )
        ],
      ),
      body: Form(
        key: formKey,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    flex: 2,
                    child: Text(
                      'People Involved: ',
                      style: TextStyle(
                          fontSize: 15,
                          color: Color.fromRGBO(124, 124, 124, 1.0)),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: FormField<List<String>>(
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
                  )
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  groupProfile.groupName,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Enter a description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 6.0,
                  ),
                  Expanded(
                      flex: 1,
                      child: InkWell(
                          onTap: () async {
                            final categoryResult =
                                await context.pushNamed<TransactionCategory>(
                                    'selectCategory');
                            if (categoryResult != null) {
                              setState(() {
                                selectedCategory = categoryResult;
                              });
                            }
                          },
                          borderRadius: BorderRadius.circular(8.0),
                          child: Container(
                            width: 60.0,
                            height: 56.0,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                    style: BorderStyle.solid, width: 0.5)),
                            child: Icon(
                              categories[selectedCategory.categoryName],
                              color: const Color.fromRGBO(116, 96, 255, 1.0),
                            ),
                          ))),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: '0.00',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 6.0,
                  ),
                  Expanded(
                      flex: 1,
                      child: InkWell(
                          onTap: () async {
                            final currencyResult = await context
                                .pushNamed<String>('selectCurrency');
                            if (currencyResult != null) {
                              setState(() {
                                _selectedCurrency = currencyResult;
                              });
                            }
                          },
                          borderRadius: BorderRadius.circular(8.0),
                          child: Container(
                            width: 60.0,
                            height: 56.0,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                    style: BorderStyle.solid, width: 0.5)),
                            child: Center(
                                child: Text(
                              _selectedCurrency,
                              style: const TextStyle(
                                  color: Color.fromRGBO(116, 96, 255, 1.0)),
                            )),
                          ))),
                ],
              ),
              const SizedBox(height: 24.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Paid by'),
                  const SizedBox(width: 8.0),
                  ElevatedButton(
                      onPressed: () async {
                        final payerResult = await context.pushNamed<String>(
                            'selectPayer',
                            extra: _selectedMembers);
                        if (payerResult != null) {
                          setState(() {
                            _selectedPayer = payerResult;
                          });
                        }
                      },
                      style: ButtonStyle(
                          elevation: const WidgetStatePropertyAll(0.0),
                          backgroundColor: WidgetStateColor.transparent,
                          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                              side: const BorderSide(
                                  style: BorderStyle.solid, width: 0.5),
                              borderRadius: BorderRadius.circular(12.0)))),
                      child: Text(
                        _selectedPayer,
                        style: const TextStyle(
                            color: Color.fromRGBO(116, 96, 255, 1.0)),
                      )),
                  const SizedBox(width: 8.0),
                  const Text('and split'),
                  const SizedBox(width: 8.0),
                  ElevatedButton(
                      onPressed: () async {
                        final splitResult = await context
                            .pushNamed<String>('selectSplitMethod');
                        if (splitResult != null) {
                          setState(() {
                            _selectedSplitMethod = splitResult;
                          });
                        }
                      },
                      style: ButtonStyle(
                          elevation: const WidgetStatePropertyAll(0.0),
                          backgroundColor: WidgetStateColor.transparent,
                          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                              side: const BorderSide(
                                  style: BorderStyle.solid, width: 0.5),
                              borderRadius: BorderRadius.circular(12.0)))),
                      child: Text(
                        _selectedSplitMethod,
                        style: const TextStyle(
                            color: Color.fromRGBO(116, 96, 255, 1.0)),
                      )),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('When'),
                  const SizedBox(width: 8.0),
                  ElevatedButton(
                      onPressed: () {},
                      style: ButtonStyle(
                          elevation: const WidgetStatePropertyAll(0.0),
                          backgroundColor: WidgetStateColor.transparent,
                          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                              side: const BorderSide(
                                  style: BorderStyle.solid, width: 0.5),
                              borderRadius: BorderRadius.circular(12.0)))),
                      child: Text(
                        _selectedDateTime,
                        style: const TextStyle(
                            color: Color.fromRGBO(116, 96, 255, 1.0)),
                      )),
                  const SizedBox(width: 8.0),
                  const Text('Rates'),
                  const SizedBox(width: 8.0),
                  ElevatedButton(
                      onPressed: () {},
                      style: ButtonStyle(
                          elevation: const WidgetStatePropertyAll(0.0),
                          backgroundColor: WidgetStateColor.transparent,
                          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                              side: const BorderSide(
                                  style: BorderStyle.solid, width: 0.5),
                              borderRadius: BorderRadius.circular(12.0)))),
                      child: Text(
                        _selectedRateMethod,
                        style: const TextStyle(
                            color: Color.fromRGBO(116, 96, 255, 1.0)),
                      )),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
