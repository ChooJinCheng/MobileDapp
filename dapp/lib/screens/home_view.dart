import 'package:dapp/global_state/providers/ethereum_service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:dapp/widgets/welcome_title.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  @override
  Widget build(BuildContext context) {
    //TODO: Init EthService at Loading page and remove this line
    final ethereumService = ref.read(ethereumServiceProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          ethereumService.userAddress.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: const Column(
        children: [
          SizedBox(
            height: 150,
          ),
          Center(
            child: WelcomeTitle(),
          ),
        ],
      ),
    );
  }
}
