import 'package:dapp/global_state/providers/ethereum_service_provider.dart';
import 'package:dapp/services/event_listener_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final eventListenerManagerProvider = Provider<EventListenerManager>((ref) {
  final ethereumService = ref.watch(ethereumServiceProvider);
  return EventListenerManager(ethereumService);
});
