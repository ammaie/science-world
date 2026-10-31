import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';

class AuthService {
  SupabaseClient? get _client => SupabaseConfig.isConfigured ? Supabase.instance.client : null;

  bool get isConfigured => SupabaseConfig.isConfigured;

  Future<AuthResponse> signUp(String email, String password) async {
    final c = _client;
    if (c == null) throw Exception('Supabase غير مهيأ');
    return c.auth.signUp(email: email, password: password);
  }

  Future<AuthResponse> signIn(String email, String password) async {
    final c = _client;
    if (c == null) throw Exception('Supabase غير مهيأ');
    return c.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    final c = _client;
    if (c == null) return;
    await c.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    final c = _client;
    if (c == null) throw Exception('Supabase غير مهيأ');
    await c.auth.resetPasswordForEmail(email);
  }

  Future<void> verifyOtp(String email, String token) async {
    final c = _client;
    if (c == null) throw Exception('Supabase غير مهيأ');
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedToken = token.trim();
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(normalizedEmail)) {
      throw ArgumentError('بريد إلكتروني غير صالح');
    }
    if (!RegExp(r'^\d{6}$').hasMatch(normalizedToken)) {
      throw ArgumentError('رمز التحقق يجب أن يتكون من 6 أرقام');
    }
    await c.auth.verifyOTP(email: normalizedEmail, token: normalizedToken, type: OtpType.signup);
  }

  Future<void> resendOtp(String email) async {
    final c = _client;
    if (c == null) throw Exception('Supabase غير مهيأ');
    final normalizedEmail = email.trim().toLowerCase();
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(normalizedEmail)) {
      throw ArgumentError('بريد إلكتروني غير صالح');
    }
    await c.auth.resend(email: normalizedEmail, type: OtpType.signup);
  }

  Future<void> updateDisplayName(String name) async {
    final c = _client;
    if (c == null) throw Exception('Supabase غير مهيأ');
    await c.auth.updateUser(UserAttributes(data: {'full_name': name.trim()}));
  }

  User? get currentUser => _client?.auth.currentUser;
  Stream<AuthState> get authStateChanges => _client?.auth.onAuthStateChange ?? const Stream.empty();
}
