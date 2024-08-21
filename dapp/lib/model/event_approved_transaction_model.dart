import 'package:web3dart/web3dart.dart';

class EventApprovedTransaction {
  String groupName;
  DateTime date;
  String transactID;
  EthereumAddress approver;

  EventApprovedTransaction({
    required this.groupName,
    required this.date,
    required this.transactID,
    required this.approver,
  });
}
