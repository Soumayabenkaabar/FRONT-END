import '../core/supabase_config.dart';
import '../models/membre.dart';

class MembreService {
  static final supabase = SupabaseConfig.client;

  static Future<List<Membre>> getMembres() async {
    final data = await supabase.from('membres').select();

    print("MEMBRES: $data");

    return (data as List)
        .map((e) => Membre.fromJson(e))
        .toList();
  }

  static Future<void> addMembre(Membre membre) async {
    final res = await supabase
        .from('membres')
        .insert(membre.toJson())
        .select();

    print("INSERT MEMBRE: $res");
  }
}