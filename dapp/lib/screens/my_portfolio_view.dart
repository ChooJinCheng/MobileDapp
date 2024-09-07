import 'package:dapp/enum/transaction_grouping_status_enum.dart';
import 'package:dapp/global_state/providers/group_profile_state_provider.dart';
import 'package:dapp/global_state/providers/transaction_state_provider.dart';
import 'package:dapp/model/user_transaction_model.dart';
import 'package:dapp/widgets/empty_message_card.dart';
import 'package:dapp/widgets/recent_transaction_list.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:dapp/model/group_profile_model.dart';
import 'package:dapp/widgets/group_carousel_card.dart';
import 'package:dapp/widgets/portfolio_card.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyPortfolioView extends ConsumerStatefulWidget {
  const MyPortfolioView({super.key});

  @override
  ConsumerState<MyPortfolioView> createState() => _MyPortfolioViewState();
}

class _MyPortfolioViewState extends ConsumerState<MyPortfolioView> {
  @override
  void initState() {
    _initGroupProfileState();
    _initTransactionState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    Map<String, GroupProfile> groupProfileProvider =
        ref.watch(groupProfileStateProvider);
    Map<String, Map<String, List<UserTransaction>>> transactionProvider =
        ref.watch(transactionStateProvider);

    List<GroupProfile> groupProfiles = groupProfileProvider.values.toList();

    String totalAmount = _getTotalBalance(groupProfiles);

    List<Widget> groupCards = groupProfiles
        .map((group) => groupCarouselCard(
            group.groupName, group.deposit, group.groupImagePath))
        .toList();
    String groupCount = groupCards.length.toString();
    if (groupCards.isEmpty) {
      groupCards.add(emptyMessageCard('You are not in any group'));
    }

    List<UserTransaction> userTransactions =
        _getRecentTransactions(transactionProvider);

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        backgroundColor: Colors.white,
        title: const Text(
          'My Portfolio',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              portfolioCard(totalAmount), //TODO: Integrate wallet value
              const SizedBox(height: 16.0),
              Text('You are in $groupCount groups',
                  style: const TextStyle(
                      fontSize: 18.0, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8.0),
              FlutterCarousel(
                  items: groupCards,
                  options: CarouselOptions(
                    autoPlay: false,
                    viewportFraction: 0.8,
                    height: deviceSize.height * 0.30,
                    enableInfiniteScroll: true,
                    slideIndicator: const CircularSlideIndicator(),
                    enlargeCenterPage: true,
                    disableCenter: true,
                    initialPage: 0,
                  )),
              const SizedBox(height: 16.0),
              recentTransactionList(userTransactions, deviceSize.width)
            ],
          )),
    );
  }

  List<UserTransaction> _getRecentTransactions(
      Map<String, Map<String, List<UserTransaction>>> transactionProvider) {
    List<UserTransaction> recentTransactions = [];

    for (String groupID in transactionProvider.keys) {
      List<UserTransaction>? transactions = transactionProvider[groupID]
          ?[TransactionGroupingStatus.otherStatus.name];

      if (transactions != null && transactions.isNotEmpty) {
        List<UserTransaction> top3Transactions = transactions.take(3).toList();
        recentTransactions.addAll(top3Transactions);
      }
    }
    recentTransactions.sort((a, b) => b.date.compareTo(a.date));

    return recentTransactions.take(3).toList();
  }

  String _getTotalBalance(List<GroupProfile> groupProfiles) {
    Decimal totalAmount = Decimal.fromInt(0);

    for (GroupProfile group in groupProfiles) {
      totalAmount += Decimal.parse(group.deposit);
    }

    return totalAmount.toStringAsFixed(2);
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
