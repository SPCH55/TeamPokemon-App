import 'package:get/get.dart';
import '../models/pokemon.dart';

class ApiService {
  final client = GetConnect();

  Future<List<Pokemon>> fetchPokemons({int limit = 40, int offset = 0}) async {
    final resp = await client.get(
      'https://pokeapi.co/api/v2/pokemon?limit=$limit&offset=$offset',
    );
    if (resp.statusCode == 200) {
      final List results = resp.body['results'];
      return results.map((e) => Pokemon.fromApiListItem(e)).toList();
    }
    return [];
  }
}
