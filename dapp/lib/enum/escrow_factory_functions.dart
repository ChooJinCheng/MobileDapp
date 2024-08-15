enum EscrowFactoryFunctions {
  deployEscrow,
  getEscrow,
  getMyGroupsEscrow,
}

extension EscrowFactoryFunctionsExtension on EscrowFactoryFunctions {
  String get functionName {
    switch (this) {
      case EscrowFactoryFunctions.deployEscrow:
        return 'deployEscrow';
      case EscrowFactoryFunctions.getEscrow:
        return 'getEscrow';
      case EscrowFactoryFunctions.getMyGroupsEscrow:
        return 'getMyGroupsEscrow';
      default:
        throw ArgumentError('Invalid function');
    }
  }
}
