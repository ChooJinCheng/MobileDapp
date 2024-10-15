import 'package:dapp/global_state/providers/wallet_connection_service_provider.dart';
import 'package:dapp/services/wallet_connection_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'dart:io';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  late WalletConnectionService _walletConnectionService;

  @override
  void initState() {
    super.initState();
    _walletConnectionService = ref.read(walletConnectionServiceProvider);
    _initializeWalletListeners();
  }

  void _initializeWalletListeners() async {
    // modal specific subscriptions
    _walletConnectionService.appKitModal.onModalDisconnect
        .subscribe(_onModalDisconnect);
    _walletConnectionService.appKitModal.onModalError.subscribe(_onModalError);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: const Text(
                  'Home',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 30),
                        Image.asset('assets/SplidappLogoWBG.png',
                            width: 200, height: 200),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(15),
                            border:
                                Border.all(color: Colors.grey.withOpacity(0.3)),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'You are connected to:',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(color: Colors.black),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _walletConnectionService.connectedAddress ??
                                    'Wallet not connected',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.normal,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (_walletConnectionService.isInitialized)
                          AppKitModalConnectButton(
                            appKit: _walletConnectionService.appKitModal,
                            size: BaseButtonSize.big,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onModalDisconnect(ModalDisconnect? event) {
    debugPrint(
        '[Splidapp.connect_wallet_view] _onModalDisconnect ${event?.toString()}');
    setState(() {});
    restartApp(context);
    // context.goNamed('Connectwallet');
  }

  void _onModalError(ModalError? event) {
    debugPrint(
        '[Splidapp.connect_wallet_view] _onModalError ${event?.toString()}');
    // When user connected to Coinbase Wallet but Coinbase Wallet does not have a session anymore
    // (for instance if user disconnected the dapp directly within Coinbase Wallet)
    // Then Coinbase Wallet won't emit any event
    if ((event?.message ?? '').contains('Coinbase Wallet Error')) {
      _walletConnectionService.appKitModal.disconnect();
    }
    setState(() {});
  }

  void restartApp(BuildContext context) {
    final WidgetsBinding binding = WidgetsBinding.instance;
    binding.addPostFrameCallback((_) {
      // This rebuilds the widget tree
      binding.reassembleApplication();

      // This forces the app to restart
      exit(0);
    });
  }
}
