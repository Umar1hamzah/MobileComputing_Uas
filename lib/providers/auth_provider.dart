import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/user.dart';

// AuthProvider bertugas mengatur status login/logout dan operasi akun
class AuthProvider extends ChangeNotifier {
  static const String _boxName = 'usersBox';

  User? _currentUser; // null = belum login
  String? _errorMessage;

  // Getter untuk diakses dari UI
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.role == 'admin'; // Getter baru
  String? get errorMessage => _errorMessage;

  // Ambil box user dari Hive
  Box<User> get _box => Hive.box<User>(_boxName);

  AuthProvider() {
    final sessionBox = Hive.box('session');
    final activeEmail = sessionBox.get('active_email');
    if (activeEmail != null) {
      _currentUser = _box.get(activeEmail);
    }
  }

  // Fungsi REGISTER: simpan akun baru ke Hive
  bool register({
    required String name,
    required String email,
    required String password,
    String? adminCode, // Tambahkan parameter adminCode
  }) {
    // Cek apakah email sudah terdaftar
    final existing = _box.values.where(
      (u) => u.email.toLowerCase() == email.toLowerCase(),
    );

    if (existing.isNotEmpty) {
      _errorMessage = 'Email sudah terdaftar. Gunakan email lain.';
      notifyListeners();
      return false;
    }

    // Tentukan role berdasarkan kode admin
    String role = 'user';
    if (adminCode == 'AKUADMINKAUHAMA') {
      role = 'admin';
    }

    // Simpan user baru ke Hive dengan email sebagai key
    final newUser = User(name: name, email: email, password: password, role: role);
    _box.put(email, newUser);

    // Langsung login setelah register berhasil
    _currentUser = newUser;
    _errorMessage = null;

    // Simpan sesi login aktif ke HP
    final sessionBox = Hive.box('session');
    sessionBox.put('active_email', email);

    notifyListeners();
    return true;
  }

  // Fungsi LOGIN: cek email & password cocok di Hive
  bool login({required String email, required String password}) {
    final user = _box.get(email);

    if (user == null) {
      _errorMessage = 'Email tidak ditemukan.';
      notifyListeners();
      return false;
    }

    if (user.password != password) {
      _errorMessage = 'Password salah.';
      notifyListeners();
      return false;
    }

    _currentUser = user;
    _errorMessage = null;

    // Simpan sesi login aktif ke HP
    final sessionBox = Hive.box('session');
    sessionBox.put('active_email', email);

    notifyListeners();
    return true;
  }

  // Fungsi LOGOUT
  void logout() {
    _currentUser = null;
    _errorMessage = null;

    // Hapus sesi login dari HP
    final sessionBox = Hive.box('session');
    sessionBox.delete('active_email');

    notifyListeners();
  }

  // Reset pesan error (dipanggil saat berpindah halaman)
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
