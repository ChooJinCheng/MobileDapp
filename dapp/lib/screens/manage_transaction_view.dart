import 'package:dapp/enum/transaction_grouping_status_enum.dart';
import 'package:dapp/global_state/providers/group_profile_state_provider.dart';
import 'package:dapp/global_state/providers/transaction_state_provider.dart';
import 'package:dapp/model/group_profile_model.dart';
import 'package:dapp/model/user_transaction_model.dart';
import 'package:dapp/utils/utils.dart';
import 'package:dapp/widgets/empty_message_card.dart';
import 'package:dapp/widgets/transaction_slidable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ManageTransactionView extends ConsumerStatefulWidget {
  const ManageTransactionView({super.key});

  @override
  ConsumerState<ManageTransactionView> createState() =>
      _ManageTransactionViewState();
}

class _ManageTransactionViewState extends ConsumerState<ManageTransactionView> {
  bool _isInitialized = false;
  Map<String, Map<String, List<UserTransaction>>> transactionsGroupedByDate =
      {};
  Map<String, String> groupContractAddresses = {};

  @override
  void initState() {
    _initGroupProfileState();
    _initTransactionState();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    Map<String, GroupProfile> groupProfile =
        ref.read(groupProfileStateProvider);
    if (groupProfile.isNotEmpty) {
      for (GroupProfile groupProfile in groupProfile.values) {
        final transactionStateNotifier =
            ref.read(transactionStateProvider.notifier);
        if (!transactionStateNotifier.isExist(groupProfile.groupID)) {
          transactionStateNotifier.loadGroupTransactions(groupProfile.groupID,
              groupProfile.groupName, groupProfile.contractAddress);
        }
      }
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, GroupProfile> groupProfileProvider =
        ref.watch(groupProfileStateProvider);
    Map<String, Map<String, List<UserTransaction>>> transactionProvider =
        ref.watch(transactionStateProvider);

    if (!_isInitialized &&
        groupProfileProvider.isNotEmpty &&
        transactionProvider.isNotEmpty) {
      transactionsGroupedByDate = _groupTransactionsByGroupAndDate(
          groupProfileProvider, transactionProvider);
      // _isInitialized = true;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Manage Transaction',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.sort_rounded),
            tooltip: 'Filter',
            iconSize: 28.0,
          )
        ],
      ),
      body: CustomScrollView(slivers: [
        const SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transaction Approval',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 8.0,
                ),
              ],
            ),
          ),
        ),
        if (transactionsGroupedByDate.isEmpty)
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
                    childCount: transactionsGroupedByDate.keys.length,
                    (context, index) {
              final groupName = transactionsGroupedByDate.keys.elementAt(index);
              final Map<String, List<UserTransaction>> transactionsByDate =
                  transactionsGroupedByDate[groupName] ?? {};
              final String contractAddress =
                  groupContractAddresses[groupName] ?? '';

              return _buildGroupSection(
                  groupName, contractAddress, transactionsByDate);
            })),
          ),
        const SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverToBoxAdapter(
            child: SizedBox(
              height: 80.0,
            ),
          ),
        ),
      ]),
    );
  }

  Map<String, Map<String, List<UserTransaction>>>
      _groupTransactionsByGroupAndDate(
          Map<String, GroupProfile> groupProfileProvider,
          Map<String, Map<String, List<UserTransaction>>> transactionProvider) {
    Map<String, Map<String, List<UserTransaction>>> groupedTransactions = {};

    for (String groupID in groupProfileProvider.keys) {
      List<UserTransaction>? transactions = transactionProvider[groupID]
          ?[TransactionGroupingStatus.pendingStatus.name];

      if (transactions != null && transactions.isNotEmpty) {
        String groupName = groupProfileProvider[groupID]?.groupName ?? '';
        groupedTransactions[groupName] = _groupByDate(transactions);

        groupContractAddresses[groupName] =
            groupProfileProvider[groupID]?.contractAddress ?? '';
      }
    }
    return groupedTransactions;
  }

  Map<String, List<UserTransaction>> _groupByDate(
      List<UserTransaction> transactions) {
    Map<String, List<UserTransaction>> transactionsByDate = {};

    for (UserTransaction transaction in transactions) {
      String formattedDate = Utils.formatDate(transaction.date);
      transactionsByDate.putIfAbsent(formattedDate, () => []).add(transaction);
    }
    return transactionsByDate;
  }

  Widget _buildGroupSection(String groupName, String contractAddress,
      Map<String, List<UserTransaction>> transactionsByDate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 5.0,
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(35, 217, 157, 0.7),
            borderRadius: BorderRadius.circular(5.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Text(
            groupName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...transactionsByDate.entries.map((entry) {
          final String date = entry.key;
          final List<UserTransaction> transactions = entry.value;

          return _buildDateSection(date, transactions, contractAddress);
        }),
      ],
    );
  }

  Widget _buildDateSection(
      String date, List<UserTransaction> transactions, String contractAddress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(
            date,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color.fromRGBO(124, 124, 124, 1.0),
            ),
          ),
        ),
        ...transactions.map((transaction) {
          return TransactionSlidable(
            userTransaction: transaction,
            groupContractAddress: contractAddress,
          );
        }),
      ],
    );
  }

  void _initGroupProfileState() {
    final groupProfileNotifier = ref.read(groupProfileStateProvider.notifier);
    if (groupProfileNotifier.isEmpty) {
      groupProfileNotifier.loadGroupProfiles();
    }
  }

  void _initTransactionState() {
    Map<String, GroupProfile> groupProfile =
        ref.read(groupProfileStateProvider);
    if (groupProfile.isNotEmpty) {
      for (GroupProfile groupProfile in groupProfile.values) {
        final transactionStateNotifier =
            ref.read(transactionStateProvider.notifier);
        if (!transactionStateNotifier.isExist(groupProfile.groupID)) {
          transactionStateNotifier.loadGroupTransactions(groupProfile.groupID,
              groupProfile.groupName, groupProfile.contractAddress);
        }
      }
    }
  }
}
