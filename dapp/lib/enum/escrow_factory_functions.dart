enum EscrowFactoryFunctions {
  deployEscrow,
  getEscrow,
  getUserEscrowMemberships,
}

extension EscrowFactoryFunctionsExtension on EscrowFactoryFunctions {
  String get functionName {
    switch (this) {
      case EscrowFactoryFunctions.deployEscrow:
        return 'deployEscrow';
      case EscrowFactoryFunctions.getEscrow:
        return 'getEscrow';
      case EscrowFactoryFunctions.getUserEscrowMemberships:
        return 'getUserEscrowMemberships';
      default:
        throw ArgumentError('Invalid function');
    }
  }
}
