import 'package:dapp/global_state/providers/wallet_connection_service_provider.dart';
import 'package:dapp/services/wallet_connection_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reown_appkit/reown_appkit.dart';

class MetaMaskConnectScreen extends ConsumerStatefulWidget {
  const MetaMaskConnectScreen({super.key});

  @override
  ConsumerState<MetaMaskConnectScreen> createState() =>
      _MetaMaskConnectScreenState();
}

class _MetaMaskConnectScreenState extends ConsumerState<MetaMaskConnectScreen> {
  late WalletConnectionService _walletConnectionService;

  @override
  void initState() {
    super.initState();
    _walletConnectionService = ref.read(walletConnectionServiceProvider);
    _initializeWalletConnection();
  }

  void _initializeWalletConnection() async {
    await _walletConnectionService.initialize(context);

    // modal specific subscriptions
    _walletConnectionService.appKitModal.onModalConnect
        .subscribe(_onModalConnect);
    _walletConnectionService.appKitModal.onModalUpdate
        .subscribe(_onModalUpdate);
    _walletConnectionService.appKitModal.onModalNetworkChange
        .subscribe(_onModalNetworkChange);
    _walletConnectionService.appKitModal.onModalDisconnect
        .subscribe(_onModalDisconnect);
    _walletConnectionService.appKitModal.onModalError.subscribe(_onModalError);
    // session related subscriptions
    _walletConnectionService.appKitModal.onSessionExpireEvent
        .subscribe(_onSessionExpired);
    _walletConnectionService.appKitModal.onSessionUpdateEvent
        .subscribe(_onSessionUpdate);
    _walletConnectionService.appKitModal.onSessionEventEvent
        .subscribe(_onSessionEvent);
    // relayClient subscriptions
    _walletConnectionService
        .appKitModal.appKit!.core.relayClient.onRelayClientConnect
        .subscribe(
      _onRelayClientConnect,
    );
    _walletConnectionService
        .appKitModal.appKit!.core.relayClient.onRelayClientError
        .subscribe(
      _onRelayClientError,
    );
    _walletConnectionService
        .appKitModal.appKit!.core.relayClient.onRelayClientDisconnect
        .subscribe(
      _onRelayClientDisconnect,
    );

    setState(() {});
  }

  @override
  void dispose() {
    _walletConnectionService
        .appKitModal.appKit!.core.relayClient.onRelayClientConnect
        .unsubscribe(
      _onRelayClientConnect,
    );
    _walletConnectionService
        .appKitModal.appKit!.core.relayClient.onRelayClientError
        .unsubscribe(
      _onRelayClientError,
    );
    _walletConnectionService
        .appKitModal.appKit!.core.relayClient.onRelayClientDisconnect
        .unsubscribe(
      _onRelayClientDisconnect,
    );
    //
    _walletConnectionService.appKitModal.onModalConnect
        .unsubscribe(_onModalConnect);
    _walletConnectionService.appKitModal.onModalUpdate
        .unsubscribe(_onModalUpdate);
    _walletConnectionService.appKitModal.onModalNetworkChange
        .unsubscribe(_onModalNetworkChange);
    _walletConnectionService.appKitModal.onModalDisconnect
        .unsubscribe(_onModalDisconnect);
    _walletConnectionService.appKitModal.onModalError
        .unsubscribe(_onModalError);
    //
    _walletConnectionService.appKitModal.onSessionExpireEvent
        .unsubscribe(_onSessionExpired);
    _walletConnectionService.appKitModal.onSessionUpdateEvent
        .unsubscribe(_onSessionUpdate);
    _walletConnectionService.appKitModal.onSessionEventEvent
        .unsubscribe(_onSessionEvent);
    //
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Connect to wallet'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/metamask_logo.png', width: 300, height: 250),
            const SizedBox(height: 20),
            Text(
              'Connect to your MetaMask wallet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            if (_walletConnectionService.isInitialized)
              AppKitModalConnectButton(
                appKit: _walletConnectionService.appKitModal,
                size: BaseButtonSize.big,
              ),
          ],
        ),
      ),
    );
  }

  //Listener handlers
  void _onModalConnect(ModalConnect? event) async {
    setState(() {});
    debugPrint(
        '[Splidapp.connect_wallet_view] _onModalConnect ${event?.session.toJson()}');
    context.goNamed('Loading');
  }

  void _onModalUpdate(ModalConnect? event) {
    setState(() {});
  }

  void _onModalNetworkChange(ModalNetworkChange? event) {
    debugPrint(
        '[Splidapp.connect_wallet_view] _onModalNetworkChange ${event?.toString()}');
    setState(() {});
  }

  void _onModalDisconnect(ModalDisconnect? event) {
    debugPrint(
        '[Splidapp.connect_wallet_view] _onModalDisconnect ${event?.toString()}');
    setState(() {});
    context.goNamed('Connectwallet');
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

  void _onSessionExpired(SessionExpire? event) {
    debugPrint(
        '[Splidapp.connect_wallet_view] _onSessionExpired ${event?.toString()}');
    setState(() {});
  }

  void _onSessionUpdate(SessionUpdate? event) {
    debugPrint(
        '[Splidapp.connect_wallet_view] _onSessionUpdate ${event?.toString()}');
    setState(() {});
  }

  void _onSessionEvent(SessionEvent? event) {
    debugPrint(
        '[Splidapp.connect_wallet_view] _onSessionEvent ${event?.toString()}');
    setState(() {});
  }

  void _onRelayClientConnect(EventArgs? event) {
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Relay connected')),
    );
  }

  void _onRelayClientError(EventArgs? event) {
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Relay disconnected')),
    );
  }

  void _onRelayClientDisconnect(EventArgs? event) {
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Relay disconnected: ${event?.toString()}')),
    );
  }
}
