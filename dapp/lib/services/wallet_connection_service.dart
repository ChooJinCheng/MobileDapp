import 'package:flutter/material.dart';
import 'package:reown_appkit/reown_appkit.dart';

class WalletConnectionService {
  late ReownAppKitModal _appKitModal;
  bool _initialized = false;

  ReownAppKitModal get appKitModal => _appKitModal;

  bool get isInitialized => _initialized;

  bool get isConnected => _appKitModal.isConnected;

  String? get connectedAddress => _appKitModal.session?.address;

  Future<void> initialize(BuildContext context) async {
    final testNetworks = ReownAppKitModalNetworks.test['eip155'] ?? [];
    final customNetwork = ReownAppKitModalNetworkInfo(
      name: 'Localhost',
      chainId: '1337',
      currency: 'ETH',
      rpcUrl: 'http://localhost:8545',
      explorerUrl: 'https://etherscan.io',
      isTestNetwork: true,
    );
    ReownAppKitModalNetworks.addNetworks('eip155', testNetworks);
    ReownAppKitModalNetworks.addNetworks('eip155', [customNetwork]);

    try {
      _appKitModal = ReownAppKitModal(
        context: context,
        projectId: '4c81f7a5a1c6db0febe71e1d8ceaae73',
        metadata: _pairingMetadata(),
        // requiredNamespaces: {},
        // optionalNamespaces: {},
        // includedWalletIds: {},
        featuredWalletIds: {
          'c57ca95b47569778a828d19178114f4db188b89b763c899ba0be274e97267d96', // Metamask
        },
        excludedWalletIds: {
          'fd20dc426fb37566d803205b19bbc1d4096b248ac04548e3cfb6b3a38bd033aa', // Coinbase
        },
        // MORE WALLETS https://explorer.walletconnect.com/?type=wallet&chains=eip155%3A1
      );
      _initialized = true;
    } on ReownAppKitModalException catch (e) {
      debugPrint('⛔️ ${e.message}');
      return;
    }
    await _appKitModal.init();
  }

  String _universalLink() {
    Uri link = Uri.parse('https://appkit-lab.reown.com/flutter_appkit');
    return link.toString();
  }

  Redirect _constructRedirect() {
    return const Redirect(
      native: 'web3Splidapp://',
      //universal: _universalLink(),
      // enable linkMode on Wallet so Dapps can use relay-less connection
      // universal: value must be set on cloud config as well
      linkMode: true,
    );
  }

  PairingMetadata _pairingMetadata() {
    return PairingMetadata(
      name: 'Splidapp',
      description: 'Splidapp',
      url: _universalLink(),
      icons: [
        'https://docs.walletconnect.com/assets/images/web3modalLogo-2cee77e07851ba0a710b56d03d4d09dd.png'
      ],
      redirect: _constructRedirect(),
    );
  }
}
