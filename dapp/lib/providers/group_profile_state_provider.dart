import 'package:dapp/model/group_profile_model.dart';
import 'package:dapp/notifiers/group_profile_state_notifier.dart';
import 'package:dapp/providers/ethereum_service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final groupProfileStateProvider =
    StateNotifierProvider<GroupProfileNotifier, Map<String, GroupProfile>>(
        (ref) {
  final ethereumService = ref.watch(ethereumServiceProvider);
  return GroupProfileNotifier(ethereumService);
});
