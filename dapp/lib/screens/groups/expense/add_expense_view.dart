import 'package:dapp/enum/transaction_category_enum.dart';
import 'package:dapp/global_state/providers/transaction_service_provider.dart';
import 'package:dapp/model/constants/categories_mapping.dart';
import 'package:dapp/model/group_profile_model.dart';
import 'package:dapp/utils/utils.dart';
import 'package:dapp/widgets/member_multi_choice_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:web3dart/web3dart.dart';

class AddExpenseView extends ConsumerStatefulWidget {
  final GroupProfile groupProfile;
  const AddExpenseView({super.key, required this.groupProfile});

  @override
  ConsumerState<AddExpenseView> createState() => _AddExpenseViewState();
}

class _AddExpenseViewState extends ConsumerState<AddExpenseView> {
  Map<String, String> _memberNameToAddresses = {};
  List<String> _selectedPayers = [];
  List<String> _groupMemberNames = [];

  TransactionCategory _selectedCategory = TransactionCategory.food;
  String _selectedCurrency = 'USD';
  String _selectedPayee = 'You';
  String _selectedSplitMethod = 'Equally';
  DateTime? _selectedDateTime = DateTime.now();
  String _formattedDate = 'Now';
  String _selectedRateMethod = 'Market';

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void initState() {
    _loadContactAddresses();
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadContactAddresses() async {
    List<String> memberNames = [];
    List<String> memberAddresses = widget.groupProfile.memberAddresses;
    Map<String, String> contacts =
        await Utils.getMembersContactsNameToAddress(memberAddresses);

    for (String name in contacts.keys) {
      memberNames.add(name);
    }

    setState(() {
      _memberNameToAddresses = contacts;
      _groupMemberNames = memberNames;
    });
  }

  void _setSelectedPayers(List<String> value) {
    setState(() => _selectedPayers = value);
  }

  String? _validateSelectedAddresses(List<String>? value) {
    if (value == null || value.isEmpty) {
      return 'Please select at least 1 member';
    }
    return null;
  }

  String? _validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a title';
    } else if (!_isAlphanumericWithSpace(value)) {
      return 'Please enter only alphanumeric characters';
    }
    return null;
  }

  bool _isAlphanumericWithSpace(String value) {
    return RegExp(r'^[a-zA-Z0-9 ]+$').hasMatch(value);
  }

  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an amount';
    } else if (!_isNumericWith2Decimal(value)) {
      return 'Please enter only valid numeric value';
    }
    return null;
  }

  bool _isNumericWith2Decimal(String value) {
    return RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(value);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != _selectedDateTime) {
      String formattedDate = DateFormat('dd MMM yyyy').format(pickedDate);
      setState(() {
        _selectedDateTime = pickedDate;
        _formattedDate = formattedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final GroupProfile groupProfile = widget.groupProfile;
    final transactionService = ref.watch(transactionServiceProvider);
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
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                try {
                  String title = _titleController.text;
                  String amount = _amountController.text;
                  int day = _selectedDateTime!.day;
                  int month = _selectedDateTime!.month;
                  int year = _selectedDateTime!.year;
                  List<EthereumAddress> selectedPayers = _selectedPayers
                      .map((memberName) => EthereumAddress.fromHex(
                          _memberNameToAddresses[memberName]!))
                      .toList();

                  List<dynamic> args = [
                    groupProfile.groupName,
                    title,
                    BigInt.from(_selectedCategory.value),
                    EthereumAddress.fromHex(
                        _memberNameToAddresses[_selectedPayee]!),
                    selectedPayers,
                    BigInt.from(int.parse(amount)),
                    BigInt.from(day),
                    BigInt.from(month),
                    BigInt.from(year)
                  ];
                  transactionService.initiateNewTransaction(
                      groupProfile.contractAddress, args);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Expense Added Successfully')),
                  );
                  context.pop();
                } catch (e) {
                  print('Error: $e');
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Error encountered. Please try again')));
                }
              }
            },
            icon: const Icon(Icons.add_box_rounded),
            tooltip: 'Add Expense',
            iconSize: 28.0,
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
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
                        'Select Payer(s): ',
                        style: TextStyle(
                            fontSize: 15,
                            color: Color.fromRGBO(124, 124, 124, 1.0)),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: FormField<List<String>>(
                        initialValue: _selectedPayers,
                        validator: _validateSelectedAddresses,
                        builder: (FormFieldState<List<String>> state) {
                          return Column(
                            children: [
                              membersMultiChoiceInput(state, _selectedPayers,
                                  _memberNameToAddresses, _setSelectedPayers),
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
                        controller: _titleController,
                        validator: _validateTitle,
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
                                  _selectedCategory = categoryResult;
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
                                categories[_selectedCategory.categoryName],
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
                        controller: _amountController,
                        validator: _validateAmount,
                        keyboardType: TextInputType.number,
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
                          final payeeResult = await context.pushNamed<String>(
                              'selectPayee',
                              extra: _groupMemberNames);
                          if (payeeResult != null) {
                            setState(() {
                              _selectedPayee = payeeResult;
                            });
                          }
                        },
                        style: ButtonStyle(
                            elevation: const WidgetStatePropertyAll(0.0),
                            backgroundColor: WidgetStateColor.transparent,
                            shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                    side:
                                        const BorderSide(
                                            style: BorderStyle.solid,
                                            width: 0.5),
                                    borderRadius:
                                        BorderRadius.circular(12.0)))),
                        child: Text(
                          _selectedPayee,
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
                            shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                    side:
                                        const BorderSide(
                                            style: BorderStyle.solid,
                                            width: 0.5),
                                    borderRadius:
                                        BorderRadius.circular(12.0)))),
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
                        onPressed: () {
                          _selectDate(context);
                        },
                        style: ButtonStyle(
                            elevation: const WidgetStatePropertyAll(0.0),
                            backgroundColor: WidgetStateColor.transparent,
                            shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                    side:
                                        const BorderSide(
                                            style: BorderStyle.solid,
                                            width: 0.5),
                                    borderRadius:
                                        BorderRadius.circular(12.0)))),
                        child: Text(
                          _formattedDate,
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
                            shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                    side:
                                        const BorderSide(
                                            style: BorderStyle.solid,
                                            width: 0.5),
                                    borderRadius:
                                        BorderRadius.circular(12.0)))),
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
      ),
    );
  }
}
