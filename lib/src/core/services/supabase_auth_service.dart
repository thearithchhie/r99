import 'package:r99/src/utilities/app_load_env.dart';
import 'package:r99/src/utilities/enum.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService {
  SupabaseAuthService._();

  static bool _initialized = false;

  static bool get isConfigured {
    return AppLoadEnv.supabaseUrl.isNotEmpty &&
        AppLoadEnv.supabaseAnonKey.isNotEmpty;
  }

  static bool get isInitialized => _initialized;

  static SupabaseClient get client => Supabase.instance.client;

  static bool get isSignedIn {
    return _initialized && client.auth.currentSession != null;
  }

  static Stream<bool> get authStateChanges {
    return client.auth.onAuthStateChange.map((state) => state.session != null);
  }

  static Future<void> initialize() async {
    if (!isConfigured) {
      _initialized = false;
      return;
    }

    await Supabase.initialize(
      url: AppLoadEnv.supabaseUrl,
      anonKey: AppLoadEnv.supabaseAnonKey,
    );
    _initialized = true;
  }

  static Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    if (!_initialized) {
      throw Exception(
        'Supabase is not configured. Add SUPABASE_URL and SUPABASE_ANON_KEY to .env.',
      );
    }

    AuthResponse response;
    try {
      response = await client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
    } on AuthException catch (error) {
      final friendlyMessage = _friendlyAuthErrorMessage(error);
      if (friendlyMessage != null) {
        throw Exception(friendlyMessage);
      }
      if (SupabaseAuthErrorCode.fromKey(error.code) ==
              SupabaseAuthErrorCode.invalidCredentials ||
          error.message.toLowerCase().contains('invalid login credentials')) {
        throw Exception(SupabaseAuthErrorCode.invalidCredentials.message);
      }
      rethrow;
    }

    if (response.session == null) {
      throw Exception('Login failed. Please check your email and password.');
    }
  }

  static Future<bool> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    if (!_initialized) {
      throw Exception(
        'Supabase is not configured. Add SUPABASE_URL and SUPABASE_ANON_KEY to .env.',
      );
    }

    AuthResponse response;
    try {
      response = await client.auth.signUp(
        email: email.trim(),
        password: password,
      );
    } on AuthException catch (error) {
      final friendlyMessage = _friendlyAuthErrorMessage(error);
      if (friendlyMessage != null) {
        throw Exception(friendlyMessage);
      }
      if (SupabaseAuthErrorCode.fromKey(error.code) ==
              SupabaseAuthErrorCode.overEmailSendRateLimit ||
          error.message.toLowerCase().contains('email rate limit')) {
        throw Exception(SupabaseAuthErrorCode.overEmailSendRateLimit.message);
      }
      rethrow;
    }

    return response.session != null;
  }

  static Future<void> signOut() async {
    if (!_initialized) return;
    await client.auth.signOut();
  }

  static String? _friendlyAuthErrorMessage(AuthException error) {
    final text = '${error.runtimeType} ${error.message}'.toLowerCase();
    if (error is AuthRetryableFetchException ||
        text.contains('socketfailed') ||
        text.contains('host lookup') ||
        text.contains('failed host lookup') ||
        text.contains('no address associated with hostname') ||
        text.contains('clientexception')) {
      return SupabaseAuthErrorCode.networkUnavailable.message;
    }
    return null;
  }
}
