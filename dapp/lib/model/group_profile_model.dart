class GroupProfile {
  String groupID;
  String groupName;
  String contractAddress;
  String deposit;
  String groupImagePath;
  String membersCount;
  List<String> memberAddresses;

  GroupProfile(
      {required this.groupID,
      required this.groupName,
      required this.contractAddress,
      required this.deposit,
      required this.groupImagePath,
      required this.membersCount,
      required this.memberAddresses});
}
