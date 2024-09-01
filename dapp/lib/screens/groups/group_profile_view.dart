import 'package:dapp/enum/transaction_grouping_status_enum.dart';
import 'package:dapp/global_state/providers/transaction_state_provider.dart';
import 'package:dapp/model/group_profile_model.dart';
import 'package:dapp/model/user_transaction_model.dart';
import 'package:dapp/global_state/providers/group_profile_state_provider.dart';
import 'package:dapp/widgets/empty_message_card.dart';
import 'package:dapp/widgets/group_profile_card.dart';
import 'package:dapp/widgets/transaction_list_card.dart';
import 'package:dapp/widgets/transaction_slidable.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class GroupProfileView extends ConsumerStatefulWidget {
  final String groupID;
  const GroupProfileView({super.key, required this.groupID});

  @override
  ConsumerState<GroupProfileView> createState() => _GroupProfileViewState();
}

class _GroupProfileViewState extends ConsumerState<GroupProfileView> {
  late List<String> filterList;
  String filterValue = 'All';

  @override
  void initState() {
    filterList = _generateFilterList();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    GroupProfile? groupProfile =
        ref.read(groupProfileStateProvider)[widget.groupID];
    if (groupProfile != null) {
      final transactionStateNotifier =
          ref.read(transactionStateProvider.notifier);
      print('didChangeDependencies triggered');
      if (!transactionStateNotifier.isExist(widget.groupID)) {
        print('Load profile triggered');
        transactionStateNotifier.loadGroupTransactions(groupProfile.groupID,
            groupProfile.groupName, groupProfile.contractAddress);
      }
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    GroupProfile? groupProfile =
        ref.watch(groupProfileStateProvider)[widget.groupID];
    if (groupProfile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    Map<String, List<UserTransaction>>? statusToTransactions =
        ref.watch(transactionStateProvider)[groupProfile.groupID];
    if (statusToTransactions == null) {
      return const Center(child: CircularProgressIndicator());
    }
    List<UserTransaction> pendingTransactions =
        statusToTransactions[TransactionGroupingStatus.pendingStatus.name] ??
            [];
    List<UserTransaction> pastTransactions =
        statusToTransactions[TransactionGroupingStatus.otherStatus.name] ?? [];

    List<UserTransaction> filteredPastTransactions = (filterValue == 'All')
        ? pastTransactions
        : _filterTransactions(pastTransactions, filterValue);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        backgroundColor: Colors.white,
        title: Text(
          groupProfile.groupName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: Align(
        alignment: const Alignment(1.0, 0.79),
        child: FloatingActionButton.extended(
          elevation: 0.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          label: const Text('Add Expense'),
          icon: const Icon(Icons.add_circle_outline),
          foregroundColor: Colors.white,
          backgroundColor: const Color.fromRGBO(35, 217, 157, 1.0),
          onPressed: () {
            context.pushNamed('addExpense', extra: groupProfile);
          },
        ),
      ),
      body: CustomScrollView(slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                groupProfileCard(groupProfile,
                    pendingTransactions.length.toString(), context),
                const SizedBox(
                  height: 16.0,
                ),
                const Text(
                  'Pending Transactions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 8.0,
                ),
              ],
            ),
          ),
        ),
        if (pendingTransactions.isEmpty)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  emptyMessageCard('You do not have any pending transaction'),
                  const SizedBox(height: 10.0)
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 12.0),
            sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                    childCount: pendingTransactions.length,
                    (context, index) => TransactionSlidable(
                          userTransaction: pendingTransactions[index],
                          groupContractAddress: groupProfile.contractAddress,
                        ))),
          ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  'Transactions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                DropdownButtonHideUnderline(
                    child: DropdownButton2<String>(
                  //isExpanded: true,
                  items: filterList
                      .map((String item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ))
                      .toList(),
                  value: filterValue,
                  onChanged: (value) {
                    setState(() {
                      filterValue = value!;
                      filteredPastTransactions =
                          _filterTransactions(pastTransactions, filterValue);
                    });
                  },
                  buttonStyleData: ButtonStyleData(
                    height: 40,
                    width: 100,
                    padding: const EdgeInsets.only(left: 24, right: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.0),
                      color: const Color.fromRGBO(35, 217, 157, 0.7),
                    ),
                  ),
                  iconStyleData: const IconStyleData(
                    icon: Icon(
                      Icons.arrow_drop_down,
                    ),
                    iconSize: 25,
                    iconEnabledColor: Colors.white,
                  ),
                  dropdownStyleData: DropdownStyleData(
                    maxHeight: 180,
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: const Color.fromRGBO(35, 217, 157, 0.7),
                    ),
                    scrollbarTheme: ScrollbarThemeData(
                      radius: const Radius.circular(40),
                      thickness: WidgetStateProperty.all(6),
                      thumbVisibility: WidgetStateProperty.all(true),
                    ),
                  ),
                  menuItemStyleData: const MenuItemStyleData(
                    height: 40,
                    padding: EdgeInsets.only(left: 14, right: 14),
                  ),
                )),
              ],
            ),
          ),
        ),
        if (filteredPastTransactions.isEmpty)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverToBoxAdapter(
              child: emptyMessageCard('You have not made any transaction'),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 100.0),
            sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                    childCount: filteredPastTransactions.length,
                    (context, index) =>
                        transactionListCard(filteredPastTransactions[index]))),
          ),
      ]),
    );
  }
}

List<String> _generateFilterList() {
  final now = DateTime.now();
  final formatter = DateFormat('MMM');
  final months = <String>[];

  for (int i = 2; i >= 0; i--) {
    final date = DateTime(now.year, now.month - i);

    if (date.month < 1) {
      final newYear = now.year - 1;
      final newMonth = date.month + 12;
      months.add(formatter.format(DateTime(newYear, newMonth)));
    } else {
      months.add(formatter.format(date));
    }
  }

  months.add('All');
  months.sort(
      (a, b) => months.indexOf(a) - months.indexOf(b)); // Ensure 'All' is last

  return months;
}

List<UserTransaction> _filterTransactions(
    List<UserTransaction> transactions, String filterValue) {
  if (transactions.isEmpty) return [];
  final now = DateTime.now();
  final filterDate = filterValue == 'All'
      ? null
      : DateTime(now.year, _getMonthIndex(filterValue));

  return transactions.where((transaction) {
    final transactionDate = transaction.date;
    if (filterDate == null) return true;
    if (transactionDate.year == filterDate.year) {
      return transactionDate.month == filterDate.month;
    } else if (transactionDate.year == filterDate.year - 1) {
      return transactionDate.month == filterDate.month;
    }
    return false;
  }).toList();
}

int _getMonthIndex(String month) {
  final months = {
    'Jan': 1,
    'Feb': 2,
    'Mar': 3,
    'Apr': 4,
    'May': 5,
    'Jun': 6,
    'Jul': 7,
    'Aug': 8,
    'Sep': 9,
    'Oct': 10,
    'Nov': 11,
    'Dec': 12,
  };
  return months[month] ?? DateTime.now().month;
}
