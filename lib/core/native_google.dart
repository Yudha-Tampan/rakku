import 'package:google_sign_in/google_sign_in.dart';
import 'package:rakku/core/google_config.dart';

abstract final class NativeGoogle {
  static Future<void>? _initialization;

  static Future<void> _ensureInitialized() {
    return _initialization ??= GoogleSignIn.instance.initialize(serverClientId: googleServerClientId).catchError((Object error) {
      _initialization = null;
      throw error;
    });
  }

  static Future<Map<String, Object>> signIn() async {
    try {
      await _ensureInitialized();
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken ?? '';
      if (idToken.isEmpty) {
        return {'error': 'Token Google tidak tersedia. Coba lagi.'};
      }
      return {'credential': idToken};
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        return {'canceled': true};
      }
      return {'error': 'Gagal masuk dengan Google (${error.code.name}).'};
    } catch (_) {
      return {'error': 'Gagal masuk dengan Google. Coba lagi.'};
    }
  }
}
