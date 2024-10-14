import 'package:dapp/global_state/providers/ethereum_service_provider.dart';
import 'package:dapp/utils/contact_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoadingView extends ConsumerStatefulWidget {
  const LoadingView({super.key});

  @override
  ConsumerState<LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends ConsumerState<LoadingView> {
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    await Future.delayed(const Duration(seconds: 2));

    try {
      final ethereumService = ref.read(ethereumServiceProvider);
      await ethereumService.initialize();
      _initializeContacts(ethereumService.userAddress.toString());

      if (mounted) {
        context.goNamed('Home');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to initialize, please try again';
      });
    }
  }

  void _initializeContacts(String userAddress) async {
    await ContactUtils.initializeContact(userAddress);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromRGBO(35, 217, 157, 1.0),
              Color.fromRGBO(116, 96, 255, 1.0),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Icon(
                  Icons.account_balance_wallet,
                  size: 80,
                  color: Colors.white.withOpacity(0.9),
                ),
                const SizedBox(height: 30),
                Text(
                  'Initializing Your DApp',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                if (_isLoading) ...[
                  CircularProgressIndicator(
                    color: Colors.white.withOpacity(0.9),
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Setting up your decentralized environment...',
                    style: TextStyle(color: Colors.white.withOpacity(0.8)),
                    textAlign: TextAlign.center,
                  ),
                ] else ...[
                  Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red.shade300),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _initializeServices,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color.fromRGBO(116, 96, 255, 1.0),
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('Retry Initialization',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Text(
                    'First time using the application? A smart contract will be deployed in your name.',
                    style: TextStyle(color: Colors.white.withOpacity(0.9)),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
