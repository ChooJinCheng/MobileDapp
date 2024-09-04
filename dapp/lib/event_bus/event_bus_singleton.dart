import 'package:event_bus/event_bus.dart';

class AppEventBus {
  AppEventBus._internal();

  static final EventBus _instance = EventBus();

  static EventBus get instance => _instance;
}

class EscrowRegisteredEvent {
  final String memberContractAddress;

  EscrowRegisteredEvent(this.memberContractAddress);
}

class GroupDisbandedEvent {
  final String groupID;

  GroupDisbandedEvent(this.groupID);
}

class TransactionExecutedEvent {
  final String groupID;

  TransactionExecutedEvent(this.groupID);
}
