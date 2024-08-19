enum TransactionCategory {
  food,
  activity,
  transport,
  services,
  apparel,
}

extension TransactionCategoryExtension on TransactionCategory {
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

  static TransactionCategory fromInt(int value) {
    switch (value) {
      case 0:
        return TransactionCategory.food;
      case 1:
        return TransactionCategory.activity;
      case 2:
        return TransactionCategory.transport;
      case 3:
        return TransactionCategory.services;
      case 4:
        return TransactionCategory.apparel;
      default:
        throw ArgumentError('Invalid integer value for TransactionCategory');
    }
  }
}
