enum EscrowFactoryFunctions {
  deployEscrow,
  getEscrow,
}

extension EscrowFactoryFunctionsExtension on EscrowFactoryFunctions {
  String get functionName {
    switch (this) {
      case EscrowFactoryFunctions.deployEscrow:
        return 'deployEscrow';
      case EscrowFactoryFunctions.getEscrow:
        return 'getEscrow';
      default:
        throw ArgumentError('Invalid function');
    }
  }
}
