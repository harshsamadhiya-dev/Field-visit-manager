import 'package:flutter/foundation.dart';
import '../models/app_user.dart';
import 'auth_service.dart';

class AppState extends ChangeNotifier {
  final AuthService authService = AuthService();
  AppUser? currentUser;
  bool isManager = false;

  bool get isLoggedIn => currentUser != null;

  void setUser(AppUser? user) {
    currentUser = user;
    notifyListeners();
  }

  void setIsManager(bool value) {
    isManager = value;
    notifyListeners();
  }

  Future<void> logout() async {
    await authService.signOut();
    setUser(null);
    setIsManager(false);
  }
}