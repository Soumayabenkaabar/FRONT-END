import '../core/supabase_config.dart';
import '../models/client.dart';

class ClientService {
  static final _db = SupabaseConfig.client;

  // 🔍 GET
  static Future<List<Client>> getClients() async {
    final data = await _db.from('clients').select();
    print("DATA: $data");
    return (data as List).map((e) => Client.fromJson(e)).toList();
  }

  // ➕ INSERT + création compte Auth si accesPortail = true
static Future<void> addClient(Client client) async {
  try {
    await _db.from('clients').insert(client.toJson());

    print("CLIENT ADDED ✅");

    if (client.accesPortail && client.email.isNotEmpty) {
      await _createAuthAccount(client.email);
    }
  } catch (e) {
    print("ERROR ADD CLIENT ❌: $e");
    rethrow;
  }
}

  // ✏️ UPDATE
 static Future<void> updateClient(Client client) async {
  try {
    // 🔴 sécurité obligatoire
    if (client.id == null || client.id!.isEmpty) {
      throw Exception("ID client invalide ❌");
    }

    await _db
        .from('clients')
        .update(client.toJson())
        .eq('id', client.id!);

    print("CLIENT UPDATED ✅ id=${client.id}");
  } catch (e) {
    print("ERROR UPDATE CLIENT ❌: $e");
    rethrow;
  }
}
  // 🗑️ DELETE
  static Future<void> deleteClient(String id) async {
    await _db.from('clients').delete().eq('id', id);
    print("DELETE id=$id");
  }

  // 🔐 Crée un compte Supabase Auth pour le portail client
  // Mot de passe temporaire — le client doit le changer à la première connexion
  static Future<void> _createAuthAccount(String email) async {
    try {
      await _db.auth.signUp(
        email: email,
        password: _generateTempPassword(email),
      );
      print("AUTH ACCOUNT CREATED: $email");
    } catch (e) {
      // Compte existant ou autre erreur — on ignore silencieusement
      print("AUTH (already exists or error): $e");
    }
  }

  /// Mot de passe temporaire : "Client@<4 premiers chars>2024!"
  /// Communiquer ce mot de passe au client manuellement ou via email.
  static String _generateTempPassword(String email) {
    final prefix = email.split('@').first;
    final short  = prefix.substring(0, prefix.length < 4 ? prefix.length : 4);
    return 'Client@${short}2024!';
  }

  /// Retourne le mot de passe temporaire pour l'afficher à l'admin
  static String getTempPassword(String email) => _generateTempPassword(email);
}