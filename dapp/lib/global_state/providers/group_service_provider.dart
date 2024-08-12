import 'package:dapp/global_state/providers/ethereum_service_provider.dart';
import 'package:dapp/services/group_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final groupServiceProvider = Provider<GroupService>((ref) {
  final ethereumService = ref.watch(ethereumServiceProvider);
  return GroupService(ethereumService);
});
