enum EscrowEvents {
  escrowDeployed,
  escrowRegistered,
  escrowDeregistered,
  groupCreated,
  groupDisbanded,
  transactionInitiated,
  transactionApproved,
  transactionDeclined,
  transactionExecuted
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
      case EscrowEvents.transactionInitiated:
        return 'TransactionInitiated';
      case EscrowEvents.transactionApproved:
        return 'TransactionApproved';
      case EscrowEvents.transactionDeclined:
        return 'TransactionDeclined';
      case EscrowEvents.transactionExecuted:
        return 'TransactionExecuted';
      default:
        throw ArgumentError('Invalid function');
    }
  }
}
