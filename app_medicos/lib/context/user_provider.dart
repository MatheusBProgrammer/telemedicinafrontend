import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserProvider with ChangeNotifier {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  String _id = "";

  String get id => _id;

  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  Future<void> setUser(String profissionalToken, String profissionalId) async {
    _id = profissionalId;
    await _storage.write(key: 'token', value: profissionalToken);
    notifyListeners();
  }

  Future<void> clearUser() async {
    _id = '';
    await _storage.delete(key: 'token');
    notifyListeners();
  }
}
