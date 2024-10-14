import 'package:shared_preferences/shared_preferences.dart';

class ContactUtils {
  static Future<void> initializeContact(String userAddress) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey(userAddress)) {
      await prefs.clear();
      await prefs.setString(userAddress, 'You');
    }
  }

  static Future<String?> getContact(String address) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(address);
  }

  static Future<void> storeContact(String name, String address) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(address, name);
  }

  static Future<void> deleteContact(String address) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(address);
  }

  static Future<Map<String, String>> getContactsAddressToName() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    Map<String, String> contacts = {};

    for (String key in keys) {
      if (_isValidEthereumAddress(key)) {
        final value = prefs.getString(key);
        if (value != null) {
          contacts[key] = value;
        }
      }
    }
    return contacts;
  }

  static Future<Map<String, String>> getContactsNameToAddress() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    Map<String, String> contacts = {};

    for (String key in keys) {
      if (_isValidEthereumAddress(key)) {
        final value = prefs.getString(key);
        if (value != null) {
          contacts[value] = key;
        }
      }
    }

    return contacts;
  }

  static Future<Map<String, String>> getMembersContactsNameToAddress(
      List<String> memberAddresses) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, String> contacts = {};

    for (String memberAddress in memberAddresses) {
      String name = (prefs.getString(memberAddress)) ?? memberAddress;
      contacts[name] = memberAddress;
    }

    return contacts;
  }

  static bool _isValidEthereumAddress(String address) {
    final regex = RegExp(r'^0x[a-fA-F0-9]{40}$');
    return regex.hasMatch(address);
  }
}
