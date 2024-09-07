import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:web3dart/crypto.dart';

class Utils {
  static String generateUniqueID(String groupName, String contractAddress) {
    final combined = '$groupName$contractAddress';
    final bytes = utf8.encode(combined);
    final digest = keccak256(bytes);
    return bytesToHex(digest, include0x: true);
  }

  static String formatDate(DateTime date) {
    String formattedDate = DateFormat('dd MMM yyyy').format(date);
    return formattedDate;
  }
}
