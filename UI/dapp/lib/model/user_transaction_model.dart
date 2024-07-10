class UserTransaction {
  String groupName;
  String transactionType;
  String dateTime;
  String transactAmount;
  String category;
  String totalAmount;
  String transactTitle;
  String transactInitiator;
  String transactCreditor;
  String transactStatus;
//TODO: Make certain fields into ENUM
  UserTransaction(
      {required this.groupName,
      required this.transactionType,
      required this.dateTime,
      required this.transactAmount,
      required this.category,
      required this.totalAmount,
      required this.transactTitle,
      required this.transactInitiator,
      required this.transactCreditor,
      required this.transactStatus});
}
