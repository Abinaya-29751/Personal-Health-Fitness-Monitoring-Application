// lib/providers/user_provider.dart
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;

  bool get isLoggedIn => _user != null;

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  void updateUser(User updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}