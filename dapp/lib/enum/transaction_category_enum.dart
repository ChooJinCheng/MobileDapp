enum TransactionCategory {
  food,
  activity,
  transport,
  services,
  apparel,
}

extension EscrowEventsExtension on TransactionCategory {
  int get value {
    switch (this) {
      case TransactionCategory.food:
        return 0;
      case TransactionCategory.activity:
        return 1;
      case TransactionCategory.transport:
        return 2;
      case TransactionCategory.services:
        return 3;
      case TransactionCategory.apparel:
        return 4;
      default:
        throw ArgumentError('Invalid function');
    }
  }

  String get categoryName {
    switch (this) {
      case TransactionCategory.food:
        return 'food';
      case TransactionCategory.activity:
        return 'activity';
      case TransactionCategory.transport:
        return 'transport';
      case TransactionCategory.services:
        return 'services';
      case TransactionCategory.apparel:
        return 'apparel';
      default:
        throw ArgumentError('Invalid function');
    }
  }
}
