import "dart:convert";
import "package:flutter_secure_storage/flutter_secure_storage.dart";

class BrandingStorage {
  static const _storage = FlutterSecureStorage();
  static const _kBranding = "branding_json";

  static Future<void> setBranding(Map<String, dynamic> branding) async {
    await _storage.write(key: _kBranding, value: jsonEncode(branding));
  }

  static Future<Map<String, dynamic>?> getBranding() async {
    final s = await _storage.read(key: _kBranding);
    if (s == null || s.isEmpty) return null;
    return jsonDecode(s) as Map<String, dynamic>;
  }

  static Future<void> clear() async {
    await _storage.delete(key: _kBranding);
  }
}
