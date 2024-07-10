class GroupProfile {
  int groupID;
  String groupName;
  String deposit;
  String groupImagePath;
  String latestTransactionDate;
  String membersCount;

  GroupProfile(
      {required this.groupID,
      required this.groupName,
      required this.deposit,
      required this.groupImagePath,
      required this.latestTransactionDate,
      required this.membersCount});
}
