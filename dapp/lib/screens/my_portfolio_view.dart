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
        groupID: 1,
        groupName: 'Dog Lovers',
        deposit: '100.00',
        groupImagePath: 'assets/dog.jpg',
        membersCount: '3'),
    GroupProfile(
        groupID: 2,
        groupName: 'Cat Lovers',
        deposit: '310.12',
        groupImagePath: 'assets/cat.jpg',
        membersCount: '2'),
    GroupProfile(
        groupID: 3,
        groupName: 'Bird Loverssssssssssssssssssss',
        deposit: '3154.11',
        groupImagePath: 'assets/bird.jpg',
        membersCount: '5'),
    GroupProfile(
        groupID: 4,
        groupName: 'Flower Lovers',
        deposit: '16804.37',
        groupImagePath: 'assets/flower.jpg',
        membersCount: '2')
  ];

  final List<UserTransaction> userTransactions = [
    UserTransaction(
        groupName: 'Dog Lovers',
        transactionType: 'receive',
        dateTime: '13 August, 10:00AM',
        transactAmount: '54',
        category: 'food',
        totalAmount: '162',
        transactTitle: 'Japanese Restaurant',
        transactInitiator: 'You',
        transactCreditor: 'You',
        transactStatus: 'Approved'),
    UserTransaction(
        groupName: 'Cat Lovers',
        transactionType: 'send',
        dateTime: '12 August, 11:00PM',
        transactAmount: '25',
        category: 'transport',
        totalAmount: '75',
        transactTitle: 'Grab from Jurong West to Tampines',
        transactInitiator: 'Mary',
        transactCreditor: 'Mary',
        transactStatus: 'Approved'),
    UserTransaction(
        groupName: 'Bird Lovers',
        transactionType: 'send',
        dateTime: '09 August, 09:00AM',
        transactAmount: '65',
        category: 'activity',
        totalAmount: '195',
        transactTitle: 'Bird Sight Equipment Rental',
        transactInitiator: 'Mary',
        transactCreditor: 'John',
        transactStatus: 'Approved'),
    UserTransaction(
        groupName: 'Flower Lovers',
        transactionType: 'receive',
        dateTime: '08 August, 05:00PM',
        transactAmount: '-',
        category: 'apparel',
        totalAmount: '162',
        transactTitle: 'Uniqlo flower series',
        transactInitiator: 'Mary',
        transactCreditor: 'You',
        transactStatus: 'Rejected'),
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
