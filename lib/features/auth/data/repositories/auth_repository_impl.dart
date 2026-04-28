import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_assignment/core/constants/app_constant.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  static const String _userKey = 'logged_in_user';

  User? _currentUser;

  @override
  Future<User?> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (email == mockUserEmail && password == mockUserPassword) {
      final userModel = const UserModel(
        id: '1',
        email: mockUserEmail,
        name: 'Admin User',
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(userModel.toJson()));

      _currentUser = userModel;
      return _currentUser;
    }
    return null;
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    _currentUser = null;
  }

  @override
  Future<User?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;

    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);

    if (userJson != null) {
      try {
        final Map<String, dynamic> userMap = jsonDecode(userJson);
        _currentUser = UserModel.fromJson(userMap);
        return _currentUser;
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}
