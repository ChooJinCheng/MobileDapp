enum EscrowEvents {
  escrowDeployed,
  escrowRegistered,
  escrowDeregistered,
  groupCreated,
  groupDisbanded,
}

extension EscrowEventsExtension on EscrowEvents {
  String get eventName {
    switch (this) {
      case EscrowEvents.escrowDeployed:
        return 'EscrowDeployed';
      case EscrowEvents.escrowRegistered:
        return 'EscrowRegistered';
      case EscrowEvents.escrowDeregistered:
        return 'EscrowDeregistered';
      case EscrowEvents.groupCreated:
        return 'GroupCreated';
      case EscrowEvents.groupDisbanded:
        return 'GroupDisbanded';
      default:
        throw ArgumentError('Invalid function');
    }
  }
}
