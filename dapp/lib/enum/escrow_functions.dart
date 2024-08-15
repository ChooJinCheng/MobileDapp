enum EscrowFunctions {
  depositToGroup,
  withdrawFromGroup,
  initiateTransaction,
  approveTransaction,
  getTransaction,
  createGroup,
  disbandGroup,
  addMemberToGroup,
  removeMemberFromGroup,
  getAllMemberGroupNames,
  getGroupSizeAndMemberDeposit,
  getGroupMembers,
  getGroupMemberBalance
}

extension EscrowFunctionsExtension on EscrowFunctions {
  String get functionName {
    switch (this) {
      case EscrowFunctions.depositToGroup:
        return 'depositToGroup';
      case EscrowFunctions.withdrawFromGroup:
        return 'withdrawFromGroup';
      case EscrowFunctions.initiateTransaction:
        return 'initiateTransaction';
      case EscrowFunctions.approveTransaction:
        return 'approveTransaction';
      case EscrowFunctions.getTransaction:
        return 'getTransaction';
      case EscrowFunctions.createGroup:
        return 'createGroup';
      case EscrowFunctions.disbandGroup:
        return 'disbandGroup';
      case EscrowFunctions.addMemberToGroup:
        return 'addMemberToGroup';
      case EscrowFunctions.removeMemberFromGroup:
        return 'removeMemberFromGroup';
      case EscrowFunctions.getAllMemberGroupNames:
        return 'getAllMemberGroupNames';
      case EscrowFunctions.getGroupSizeAndMemberDeposit:
        return 'getGroupSizeAndMemberDeposit';
      case EscrowFunctions.getGroupMembers:
        return 'getGroupMembers';
      case EscrowFunctions.getGroupMemberBalance:
        return 'getGroupMemberBalance';
      default:
        throw ArgumentError('Invalid function');
    }
  }
}
