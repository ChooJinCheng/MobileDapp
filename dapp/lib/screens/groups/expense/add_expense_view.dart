import 'package:choice/choice.dart';
import 'package:dapp/enum/transaction_category_enum.dart';
import 'package:dapp/model/constants/categories_mapping.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddExpenseView extends StatefulWidget {
  const AddExpenseView({super.key});

  @override
  State<AddExpenseView> createState() => _AddExpenseViewState();
}

class _AddExpenseViewState extends State<AddExpenseView> {
  final formKey = GlobalKey<FormState>();

  TransactionCategory selectedCategory = TransactionCategory.food;
  String selectedCurrency = 'USD';
  String selectedCreditor = 'You';
  String selectedSplitMethod = 'Equally';
  String selectedDateTime = 'Now';
  String selectedRateMethod = 'Market';

  List<String> members = [
    'John',
    'Mary',
    'Gerald',
    'Karen',
    'Kelvin',
  ];

  List<String> selectedMembers = [];

  void setSelectedMembers(List<String> value) {
    setState(() => selectedMembers = value);
  }

  @override
  Widget build(BuildContext context) {
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
                  Expanded(flex: 4, child: membersMultiChoiceInput())
                ],
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'Group X',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                                selectedCurrency = currencyResult;
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
                              selectedCurrency,
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
                        final creditorResult = await context.pushNamed<String>(
                            'selectCreditor',
                            extra: selectedMembers);
                        if (creditorResult != null) {
                          setState(() {
                            selectedCreditor = creditorResult;
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
                        selectedCreditor,
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
                            selectedSplitMethod = splitResult;
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
                        selectedSplitMethod,
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
                        selectedDateTime,
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
                        selectedRateMethod,
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

  Widget membersMultiChoiceInput() {
    return Choice<String>.prompt(
      title: 'Members',
      multiple: true,
      confirmation: true,
      value: selectedMembers,
      onChanged: setSelectedMembers,
      itemCount: members.length,
      itemSkip: (state, i) =>
          !ChoiceSearch.match(members[i], state.search?.value),
      itemBuilder: (state, i) {
        return CheckboxListTile(
          value: state.selected(members[i]),
          onChanged: state.onSelected(members[i]),
          title: ChoiceText(
            members[i],
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
      modalFooterBuilder: (state) {
        return Column(
          children: [
            CheckboxListTile(
              value: state.selectedMany(members),
              onChanged: state.onSelectedMany(members),
              tristate: true,
              title: const Text('Select All'),
            ),
            const SizedBox(height: 75.0)
          ],
        );
      },
      promptDelegate: ChoicePrompt.delegateBottomSheet(),
    );
  }
}
