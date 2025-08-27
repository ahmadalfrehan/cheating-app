import 'package:get_storage/get_storage.dart';

class UserCache {
  static final _storage = GetStorage();
  static const _keyName = "user_name";
  static const _keyEmail = "user_email";


  static void saveUser(String name, String email) {
    _storage.write(_keyName, name);
    _storage.write(_keyEmail, email);
  }


  static String? get name => _storage.read(_keyName);


  static String? get email => _storage.read(_keyEmail);


  static void clearUser() {
    _storage.remove(_keyName);
    _storage.remove(_keyEmail);
  }
}
