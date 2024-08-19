enum TransactionStatus {
  pending,
  declined,
  approved,
}

extension TransactionStatusExtension on TransactionStatus {
  int get value {
    switch (this) {
      case TransactionStatus.pending:
        return 0;
      case TransactionStatus.declined:
        return 1;
      case TransactionStatus.approved:
        return 2;
      default:
        throw ArgumentError('Invalid function');
    }
  }

  String get statusName {
    switch (this) {
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.declined:
        return 'Declined';
      case TransactionStatus.approved:
        return 'Approved';
      default:
        throw ArgumentError('Invalid function');
    }
  }

  static TransactionStatus fromInt(int value) {
    switch (value) {
      case 0:
        return TransactionStatus.pending;
      case 1:
        return TransactionStatus.declined;
      case 2:
        return TransactionStatus.approved;
      default:
        throw ArgumentError('Invalid integer value for TransactionStatus');
    }
  }
}
