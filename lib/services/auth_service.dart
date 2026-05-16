import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  User?                get authUser => _supabase.auth.currentUser;
  Map<String, dynamic>? _dbUser;
  Map<String, dynamic>? get dbUser => _dbUser;

  bool get isLoggedIn => authUser != null;

  // Sign in
  Future<void> signIn(String email, String password) async {
    final res = await _supabase.auth.signInWithPassword(
      email: email, password: password,
    );
    if (res.user != null) {
      await _loadDbUser(email);
      notifyListeners();
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
    _dbUser = null;
    notifyListeners();
  }

  // Load profile from users table
  Future<void> _loadDbUser(String email) async {
    try {
      final data = await _supabase
          .from('users')
          .select('*')
          .eq('email', email)
          .single();
      _dbUser = data;
    } catch (e) {
      debugPrint('Error loading DB user: $e');
      _dbUser = null;
    }
  }

  // Check existing session
  Future<void> checkSession() async {
    final session = _supabase.auth.currentSession;
    if (session != null && session.user.email != null) {
      await _loadDbUser(session.user.email!);
      notifyListeners();
    }
  }

  String get displayName {
    if (_dbUser == null) return 'Driver';
    return '${_dbUser!['first_name']} ${_dbUser!['last_name']}';
  }

  int? get dbUserId => _dbUser?['id'] as int?;

  // Update FCM token
  Future<void> updateFcmToken(String token) async {
    if (dbUserId == null) return;
    await _supabase
        .from('users')
        .update({'fcm_token': token})
        .eq('id', dbUserId!);
  }
}
