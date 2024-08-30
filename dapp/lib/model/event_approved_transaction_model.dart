import 'package:web3dart/web3dart.dart';

class EventApprovedTransaction {
  DateTime date;
  String groupName;
  String transactID;
  EthereumAddress approver;

  EventApprovedTransaction({
    required this.date,
    required this.groupName,
    required this.transactID,
    required this.approver,
  });
}
