import 'package:shared_preferences/shared_preferences.dart';

class ClientProfileStore {
  static const String _nameKey = 'foodly_client_name';
  static const String _phoneKey = 'foodly_client_phone';
  static const String _addressKey = 'foodly_client_address';

  /// Récupérer les coordonnées du client.
  static Future<Map<String, String>> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'name': prefs.getString(_nameKey) ?? '',
      'phone': prefs.getString(_phoneKey) ?? '',
      'address': prefs.getString(_addressKey) ?? '',
    };
  }

  /// Enregistrer les coordonnées du client.
  static Future<void> saveProfile({
    required String name,
    required String phone,
    required String address,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_nameKey, name);
    await prefs.setString(_phoneKey, phone);
    await prefs.setString(_addressKey, address);
  }

  /// Supprimer les coordonnées enregistrées.
  static Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_nameKey);
    await prefs.remove(_phoneKey);
    await prefs.remove(_addressKey);
  }
}
