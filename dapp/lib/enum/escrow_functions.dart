enum EscrowFunctions {
  depositToGroup,
  withdrawFromGroup,
  initiateTransaction,
  approveTransaction,
  declineTransaction,
  getTransaction,
  createGroup,
  disbandGroup,
  addMemberToGroup,
  removeMemberFromGroup,
  getAllMemberGroupNames,
  getGroupDetails,
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
      case EscrowFunctions.declineTransaction:
        return 'declineTransaction';
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
      case EscrowFunctions.getGroupDetails:
        return 'getGroupDetails';
      case EscrowFunctions.getGroupMembers:
        return 'getGroupMembers';
      case EscrowFunctions.getGroupMemberBalance:
        return 'getGroupMemberBalance';
      default:
        throw ArgumentError('Invalid function');
    }
  }
}
