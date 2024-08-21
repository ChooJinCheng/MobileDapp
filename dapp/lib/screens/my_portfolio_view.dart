import 'package:dapp/enum/transaction_category_enum.dart';
import 'package:dapp/enum/transaction_status_enum.dart';
import 'package:dapp/model/user_transaction_model.dart';
import 'package:dapp/widgets/empty_message_card.dart';
import 'package:dapp/widgets/recent_transaction_list.dart';
import 'package:flutter/material.dart';
import 'package:dapp/model/group_profile_model.dart';
import 'package:dapp/widgets/group_carousel_card.dart';
import 'package:dapp/widgets/portfolio_card.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';

class MyPortfolioView extends StatefulWidget {
  const MyPortfolioView({super.key});

  @override
  State<MyPortfolioView> createState() => _MyPortfolioViewState();
}

class _MyPortfolioViewState extends State<MyPortfolioView> {
  final List<GroupProfile> groupProfiles = [
    GroupProfile(
        groupID: 'test1',
        groupName: 'Dog Lovers',
        contractAddress: 'test1',
        deposit: '100.00',
        groupImagePath: 'assets/dog.jpg',
        membersCount: '3',
        memberAddresses: []),
    GroupProfile(
        groupID: 'test2',
        groupName: 'Cat Lovers',
        contractAddress: 'test2',
        deposit: '310.12',
        groupImagePath: 'assets/cat.jpg',
        membersCount: '2',
        memberAddresses: []),
    GroupProfile(
        groupID: 'test3',
        groupName: 'Bird Loverssssssssssssssssssss',
        contractAddress: 'test3',
        deposit: '3154.11',
        groupImagePath: 'assets/bird.jpg',
        membersCount: '5',
        memberAddresses: []),
    GroupProfile(
        groupID: 'test4',
        groupName: 'Flower Lovers',
        contractAddress: 'test4',
        deposit: '16804.37',
        groupImagePath: 'assets/flower.jpg',
        membersCount: '2',
        memberAddresses: [])
  ];

  final List<UserTransaction> userTransactions = [
    UserTransaction(
        transactID: '1',
        groupName: 'Dog Lovers',
        transactionType: true,
        date: DateTime(2024, 8, 12),
        transactAmount: '54',
        category: TransactionCategory.food,
        totalAmount: '162',
        transactTitle: 'Japanese Restaurant',
        transactInitiator: 'You',
        transactPayee: 'You',
        transactPayers: [],
        transactStatus: TransactionStatus.approved),
    UserTransaction(
        transactID: '2',
        groupName: 'Cat Lovers',
        transactionType: false,
        date: DateTime(2024, 8, 12),
        transactAmount: '25',
        category: TransactionCategory.transport,
        totalAmount: '75',
        transactTitle: 'Grab from Jurong West to Tampines',
        transactInitiator: 'Mary',
        transactPayee: 'Mary',
        transactPayers: [],
        transactStatus: TransactionStatus.approved),
    UserTransaction(
        transactID: '3',
        groupName: 'Bird Lovers',
        transactionType: false,
        date: DateTime(2024, 8, 12),
        transactAmount: '65',
        category: TransactionCategory.activity,
        totalAmount: '195',
        transactTitle: 'Bird Sight Equipment Rental',
        transactInitiator: 'Mary',
        transactPayee: 'John',
        transactPayers: [],
        transactStatus: TransactionStatus.approved),
    UserTransaction(
        transactID: '4',
        groupName: 'Flower Lovers',
        transactionType: true,
        date: DateTime(2024, 8, 12),
        transactAmount: '-',
        category: TransactionCategory.apparel,
        totalAmount: '162',
        transactTitle: 'Uniqlo flower series',
        transactInitiator: 'Mary',
        transactPayee: 'You',
        transactPayers: [],
        transactStatus: TransactionStatus.declined),
  ];

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    List<Widget> groupCards = groupProfiles
        .map((group) => groupCarouselCard(
            group.groupName, group.deposit, group.groupImagePath))
        .toList();

    String groupCount = groupCards.length.toString();
    if (groupCards.isEmpty) {
      groupCards.add(emptyMessageCard('You are not in any group'));
    }

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
              portfolioCard(),
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
}
