import 'package:flutter/foundation.dart';
import '../core/supabase_config.dart';
import '../models/client.dart';
import '../service/auth_service.dart';

class ClientService {
  static final _db = SupabaseConfig.client;

  // 🔍 GET — RLS filtre automatiquement par user_id
  static Future<List<Client>> getClients() async {
    final data = await _db.from('clients').select();
    return (data as List).map((e) => Client.fromJson(e)).toList();
  }

  // ➕ INSERT
  static Future<void> addClient(Client client) async {
    try {
      final json = client.toJson();
      json['user_id'] = AuthService.currentUser!.id; // ← isolation
      await _db.from('clients').insert(json);
      if (client.accesPortail && client.email.isNotEmpty) {
        await _createAuthAccount(client.email);
      }
    } catch (e) {
      debugPrint("ERROR ADD CLIENT: $e");
      rethrow;
    }
  }

  // ✏️ UPDATE
  static Future<void> updateClient(Client client) async {
    try {
      if (client.id.isEmpty) throw Exception("ID client invalide");
      await _db.from('clients').update(client.toJson()).eq('id', client.id);
    } catch (e) {
      debugPrint("ERROR UPDATE CLIENT: $e");
      rethrow;
    }
  }

  // 🗑️ DELETE
  static Future<void> deleteClient(String id) async {
    await _db.from('clients').delete().eq('id', id);
  }

  // 🔐 Compte portail client
  static Future<void> _createAuthAccount(String email) async {
    try {
      await _db.auth.signUp(
        email: email,
        password: _generateTempPassword(email),
      );
    } catch (e) {
      debugPrint("AUTH (already exists or error): $e");
    }
  }

  static String _generateTempPassword(String email) {
    final prefix = email.split('@').first;
    final short  = prefix.substring(0, prefix.length < 4 ? prefix.length : 4);
    return 'Client@${short}2024!';
  }

  static String getTempPassword(String email) => _generateTempPassword(email);
}