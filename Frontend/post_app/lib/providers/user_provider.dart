import 'package:flutter/foundation.dart';
import 'package:post_app/models/user_model.dart'; // Adjust import path as needed

class UserProvider with ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;

  void setUser(UserModel? user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
