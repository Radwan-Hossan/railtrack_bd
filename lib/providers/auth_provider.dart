import 'package:flutter/material.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser = const User(
    id: 'USR_001',
    name: 'Tuhin Rahman',
    email: 'tuhin@railtrack.bd',
    phone: '+8801700000000',
    role: UserRole.admin, // Default admin for testing full console
  );

  bool _isLoggedIn = false;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  void loginAsPassenger() {
    _currentUser = const User(
      id: 'USR_PASSENGER',
      name: 'Regular Commuter',
      email: 'passenger@railway.gov.bd',
      phone: '+8801811112233',
      role: UserRole.passenger,
    );
    _isLoggedIn = true;
    notifyListeners();
  }

  void loginAsAdmin() {
    _currentUser = const User(
      id: 'USR_ADMIN',
      name: 'Railway Traffic Dispatcher',
      email: 'dispatcher@railway.gov.bd',
      phone: '+8801700000000',
      role: UserRole.admin,
    );
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}
