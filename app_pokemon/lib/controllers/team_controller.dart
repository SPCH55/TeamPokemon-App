import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../models/pokemon.dart';
import '../models/team.dart';
import '../services/api_service.dart';
import '../core/storage_keys.dart';

class TeamController extends GetxController {
  final ApiService api;
  final box = GetStorage();
  TeamController(this.api);

  // Pokédex
  final pokemons = <Pokemon>[].obs;
  final filtered = <Pokemon>[].obs;
  final isLoading = false.obs;
  final query = ''.obs;

  // Multi-team
  final teams = <Team>[].obs;
  final currentTeamId = RxnString();

  @override
  void onInit() {
    super.onInit();
    _loadPersisted();
    loadPokemons();
    ever(query, (_) => _applySearch());
  }

  // -------- Pokédex --------
  Future<void> loadPokemons() async {
    isLoading.value = true;
    try {
      final list = await api.fetchPokemons(limit: 40);
      pokemons.assignAll(list);
      filtered.assignAll(list);
    } finally {
      isLoading.value = false;
    }
  }

  void _applySearch() {
    final q = query.value.trim().toLowerCase();
    if (q.isEmpty) {
      filtered.assignAll(pokemons);
    } else {
      filtered.assignAll(
        pokemons.where((p) => p.name.toLowerCase().contains(q)).toList(),
      );
    }
  }

  // -------- Teams CRUD --------
  Team? get currentTeam =>
      teams.firstWhereOrNull((t) => t.id == currentTeamId.value);

  String get currentTeamName => currentTeam?.name ?? 'My Team';

  List<Pokemon> get currentMembers => currentTeam?.members ?? const [];

  void createTeam({String name = 'New Team'}) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final t = Team(id: id, name: name, members: []);
    teams.add(t);
    selectTeam(id);
    _persistAll();
  }

  void renameTeam(String id, String name) {
    final idx = teams.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    teams[idx] = teams[idx].copyWith(
      name: name.trim().isEmpty ? 'My Team' : name.trim(),
    );
    if (currentTeamId.value == id) {
      currentTeamId.refresh();
    }
    _persistAll();
  }

  void deleteTeam(String id) {
    teams.removeWhere((t) => t.id == id);
    if (currentTeamId.value == id) {
      currentTeamId.value = teams.isNotEmpty ? teams.first.id : null;
    }
    _persistAll();
  }

  void selectTeam(String id) {
    if (teams.any((t) => t.id == id)) {
      currentTeamId.value = id;
      box.write(StorageKeys.currentTeamId, id);
    }
  }

  // -------- Edit members of current team --------
  void toggleSelect(Pokemon p) {
    final t = currentTeam;
    if (t == null) return;

    final idx = teams.indexWhere((e) => e.id == t.id);
    if (idx == -1) return;

    final members = List<Pokemon>.from(teams[idx].members);
    final exists = members.any((m) => m.id == p.id);

    if (exists) {
      members.removeWhere((m) => m.id == p.id);
    } else {
      if (members.length >= 3) {
        Get.snackbar('Team Full', 'เลือกได้สูงสุด 3 ตัว');
        return;
      }
      members.add(p);
    }

    teams[idx] = teams[idx].copyWith(members: members);
    _persistAll();
  }

  // -------- Persistence --------
  void _persistAll() {
    final list = teams.map((t) => t.toJson()).toList();
    box.write(StorageKeys.teams, list);
    if (currentTeamId.value != null) {
      box.write(StorageKeys.currentTeamId, currentTeamId.value);
    }
  }

  void _loadPersisted() {
    final rawList = box.read(StorageKeys.teams);
    if (rawList is List) {
      final restored = rawList
          .whereType<Map>()
          .map((m) => Team.fromJson(Map<String, dynamic>.from(m)))
          .toList();
      teams.assignAll(restored);
    }

    final cid = box.read(StorageKeys.currentTeamId);
    if (cid is String && teams.any((t) => t.id == cid)) {
      currentTeamId.value = cid;
    } else {
      if (teams.isNotEmpty) currentTeamId.value = teams.first.id;
    }

    if (teams.isEmpty) {
      createTeam(name: 'My Team');
    }
  }
}
