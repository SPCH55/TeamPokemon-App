class Pokemon {
  final int id;
  final String name;
  final String imageUrl;

  Pokemon({required this.id, required this.name, required this.imageUrl});

  factory Pokemon.fromApiListItem(Map<String, dynamic> item) {
    // item: { name: "...", url: "https://pokeapi.co/api/v2/pokemon/1/" }
    final url = item['url'] as String;
    final idStr = url.split('/').where((s) => s.isNotEmpty).last;
    final id = int.tryParse(idStr) ?? 0;
    final image =
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
    return Pokemon(id: id, name: item['name'], imageUrl: image);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'imageUrl': imageUrl,
      };

  factory Pokemon.fromJson(Map<String, dynamic> json) => Pokemon(
        id: json['id'],
        name: json['name'],
        imageUrl: json['imageUrl'],
      );
}
