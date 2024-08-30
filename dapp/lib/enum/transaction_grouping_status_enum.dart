enum TransactionGroupingStatus {
  pendingStatus,
  otherStatus,
}

extension TransactionGroupingStatusExtension on TransactionGroupingStatus {
  String get name {
    switch (this) {
      case TransactionGroupingStatus.pendingStatus:
        return 'pendingStatus';
      case TransactionGroupingStatus.otherStatus:
        return 'otherStatus';
      default:
        throw ArgumentError('Invalid function');
    }
  }
}
