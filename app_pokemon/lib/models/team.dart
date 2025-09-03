import 'pokemon.dart';

class Team {
  final String id;          // ใช้ string จาก timestamp
  String name;
  List<Pokemon> members;    // จำกัดจำนวนใน Controller

  Team({required this.id, required this.name, required this.members});

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'members': members.map((e) => e.toJson()).toList(),
      };

  factory Team.fromJson(Map<String, dynamic> json) => Team(
        id: json['id'] as String,
        name: json['name'] as String,
        members: (json['members'] as List)
            .map((e) => Pokemon.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );

  Team copyWith({String? id, String? name, List<Pokemon>? members}) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      members: members ?? List<Pokemon>.from(this.members),
    );
  }
}
