import 'package:flutter/material.dart';
import 'package:pickle/models/user.dart';

class AuthViewModel extends ChangeNotifier {
  User _user = User();
  int _currentStep = 0;
  bool _isLoading = false;

  User get user => _user;
  int get currentStep => _currentStep;
  bool get isLoading => _isLoading;

  void updateUser(User updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }

  void nextStep() {
    _currentStep++;
    notifyListeners();
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
