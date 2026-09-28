import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import 'database_service.dart';

class AuthService {
  final _dbService = DatabaseService.instance;
  static UserModel? currentUser;
  static final Map<String, UserModel> _webUsers = {};
  static int _nextWebUserId = 1;

  static const _sessionKey = 'session_logged_in';
  static const _idKey = 'session_id';
  static const _nameKey = 'session_name';
  static const _emailKey = 'session_email';
  static const _passwordKey = 'session_password';
  static const _photoKey = 'session_photo';

  Future<void> restoreSession() async {
    final preferences = await SharedPreferences.getInstance();
    if (preferences.getBool(_sessionKey) != true) return;

    final email = preferences.getString(_emailKey);
    final name = preferences.getString(_nameKey);
    final password = preferences.getString(_passwordKey);
    if (email == null || name == null || password == null) {
      await clearSession();
      return;
    }

    currentUser = UserModel(
      id: preferences.getInt(_idKey),
      nama: name,
      email: email,
      password: password,
      fotoProfil: preferences.getString(_photoKey),
    );

    if (kIsWeb) {
      _webUsers[email.toLowerCase()] = currentUser!;
    }
  }

  Future<void> _saveSession(UserModel user) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setBool(_sessionKey, true);
      if (user.id != null) await preferences.setInt(_idKey, user.id!);
      await preferences.setString(_nameKey, user.nama);
      await preferences.setString(_emailKey, user.email);
      await preferences.setString(_passwordKey, user.password);
      if (user.fotoProfil != null) {
        await preferences.setString(_photoKey, user.fotoProfil!);
      }
    } catch (_) {
      // Storage tidak boleh membuat proses auth berhenti.
    }
  }

  void _saveSessionWithoutBlocking(UserModel user) {
    unawaited(_saveSession(user));
  }

  Future<void> clearSession() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_sessionKey);
    await preferences.remove(_idKey);
    await preferences.remove(_nameKey);
    await preferences.remove(_emailKey);
    await preferences.remove(_passwordKey);
    await preferences.remove(_photoKey);
  }

  Future<String?> register(UserModel user) async {
    if (kIsWeb) {
      final email = user.email.trim().toLowerCase();
      if (_webUsers.containsKey(email)) return 'Email sudah terdaftar';

      user.id = _nextWebUserId++;
      _webUsers[email] = user;
      currentUser = user;
      _saveSessionWithoutBlocking(user);
      return null;
    }

    final db = await _dbService.database;
    try {
      final existing = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [user.email],
      );
      if (existing.isNotEmpty) return 'Email sudah terdaftar';
      await db.insert('users', user.toMap()..remove('id'));
      final savedUser = (await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [user.email],
        limit: 1,
      )).first;
      currentUser = UserModel.fromMap(savedUser);
      _saveSessionWithoutBlocking(currentUser!);
      return null;
    } catch (_) {
      return 'Terjadi kesalahan saat mendaftar';
    }
  }

  Future<String?> login(String email, String password) async {
    if (kIsWeb) {
      final user = _webUsers[email.trim().toLowerCase()];
      if (user == null || user.password != password) {
        return 'Email atau password salah';
      }

      currentUser = user;
      _saveSessionWithoutBlocking(user);
      return null;
    }

    final db = await _dbService.database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (result.isEmpty) return 'Email atau password salah';
    currentUser = UserModel.fromMap(result.first);
    _saveSessionWithoutBlocking(currentUser!);
    return null;
  }

  Future<void> updateProfile(UserModel user) async {
    if (kIsWeb) {
      _webUsers[user.email.trim().toLowerCase()] = user;
      currentUser = user;
      return;
    }

    final db = await _dbService.database;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
    currentUser = user;
    _saveSessionWithoutBlocking(user);
  }

  Future<String?> changePassword(String newPassword) async {
    if (currentUser == null) return 'Belum login';

    if (kIsWeb) {
      currentUser!.password = newPassword;
      _webUsers[currentUser!.email.trim().toLowerCase()] = currentUser!;
      _saveSessionWithoutBlocking(currentUser!);
      return null;
    }

    final db = await _dbService.database;
    await db.update(
      'users',
      {'password': newPassword},
      where: 'id = ?',
      whereArgs: [currentUser!.id],
    );
    currentUser!.password = newPassword;
    _saveSessionWithoutBlocking(currentUser!);
    return null;
  }

  Future<void> logout() async {
    currentUser = null;
    await clearSession();
  }
}
