import 'package:dapp/global_state/providers/group_profile_state_provider.dart';
import 'package:dapp/model/group_profile_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:slider_button/slider_button.dart';

class DepositGroupView extends ConsumerStatefulWidget {
  final GroupProfile groupProfile;

  const DepositGroupView({super.key, required this.groupProfile});

  @override
  ConsumerState<DepositGroupView> createState() => _DepositGroupPageState();
}

class _DepositGroupPageState extends ConsumerState<DepositGroupView> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an amount';
    } else if (!_isNumericWith2Decimal(value)) {
      return 'Please enter a numeric value with 2 decimal point';
    }
    return null;
  }

  bool _isNumericWith2Decimal(String value) {
    return RegExp(r'^\d+\.\d{2}$').hasMatch(value);
  }

  @override
  Widget build(BuildContext context) {
    final groupProfileStateNotifier =
        ref.read(groupProfileStateProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deposit'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 120),
                Center(
                  child: Text(
                    'Deposit to: ${widget.groupProfile.groupName}',
                    style: const TextStyle(
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: _validateAmount,
                  decoration: InputDecoration(
                      labelText: 'Deposit Amount',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      prefixIcon: const Icon(Icons.attach_money),
                      hintText: '0.00'),
                  style: const TextStyle(fontSize: 35.0),
                ),
                const SizedBox(height: 40),
                Center(
                    child: SliderButton(
                  action: () async {
                    try {
                      String amount = _amountController.text;
                      if (_formKey.currentState!.validate()) {
                        groupProfileStateNotifier.depositToGroup(
                            widget.groupProfile.groupName,
                            widget.groupProfile.contractAddress,
                            amount);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Deposit is successful!')));
                        context.pop();
                        return true;
                      }
                    } catch (e) {
                      print('Error: $e');
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content:
                              Text('Error encountered. Please try again')));
                    }
                    return false;
                  },
                  label: const Text(
                    "Slide to deposit now",
                    style: TextStyle(
                        color: Color(0xff4a4a4a),
                        fontWeight: FontWeight.w500,
                        fontSize: 17.0),
                  ),
                  icon: const Center(
                      child: Icon(
                    Icons.call_made,
                    color: Colors.white,
                    size: 30.0,
                    semanticLabel: 'Slide to deposit',
                  )),
                  boxShadow: BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                  ),
                  baseColor: const Color.fromRGBO(35, 217, 157, 1.0),
                  buttonColor: const Color.fromRGBO(35, 217, 157, 1.0),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
