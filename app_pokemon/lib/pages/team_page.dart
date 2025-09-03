import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/team_controller.dart';
import '../models/pokemon.dart';

class TeamPage extends StatelessWidget {
  const TeamPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TeamController>();

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(ctrl.currentTeamName)),
        actions: [
          IconButton(
            tooltip: 'Back to Teams',
            onPressed: () => Get.back(),
            icon: const Icon(Icons.list),
          ),
        ],
      ),
      body: Column(
        children: [
          // Rename team
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Obx(() {
                    return TextField(
                      decoration: InputDecoration(
                        labelText: 'Team Name',
                        border: const OutlineInputBorder(),
                        hintText: ctrl.currentTeamName,
                      ),
                      onSubmitted: (name) {
                        final id = ctrl.currentTeamId.value;
                        if (id != null) ctrl.renameTeam(id, name);
                      },
                    );
                  }),
                ),
              ],
            ),
          ),

          // Selected members (max 3)
          Obx(() {
            final members = ctrl.currentMembers;
            return SizedBox(
              height: 96,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) {
                  final Pokemon? p = i < members.length ? members[i] : null;
                  return _TeamSlot(
                    p: p,
                    onTap: p != null ? () => ctrl.toggleSelect(p) : null,
                  );
                },
              ),
            );
          }),

          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search Pokémon...',
                border: OutlineInputBorder(),
              ),
              onChanged: (t) => ctrl.query.value = t,
            ),
          ),

          // Pokémon list
          Expanded(
            child: Obx(() {
              if (ctrl.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              final items = ctrl.filtered;
              if (items.isEmpty) {
                return const Center(child: Text('No Pokémon found'));
              }
              final current = ctrl.currentMembers;
              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final p = items[i];
                  final selected = current.any((m) => m.id == p.id);
                  return _PokemonTile(
                    pokemon: p,
                    selected: selected,
                    onTap: () => ctrl.toggleSelect(p),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

// --- UI widgets ---
class _TeamSlot extends StatelessWidget {
  final Pokemon? p;
  final VoidCallback? onTap;
  const _TeamSlot({required this.p, this.onTap});

  @override
  Widget build(BuildContext context) {
    final child = p == null
        ? const Icon(Icons.catching_pokemon, size: 40)
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage:
                    p!.imageUrl.isNotEmpty ? NetworkImage(p!.imageUrl) : null,
                child: p!.imageUrl.isEmpty
                    ? const Icon(Icons.image_not_supported)
                    : null,
              ),
              const SizedBox(height: 6),
              Text(p!.name, style: const TextStyle(fontSize: 12)),
            ],
          );

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        width: 96,
        decoration: BoxDecoration(
          color: p == null ? Colors.grey.shade100 : Colors.blue.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blueGrey.shade200),
        ),
        padding: const EdgeInsets.all(8),
        child: Center(child: child),
      ),
    );
  }
}

class _PokemonTile extends StatelessWidget {
  final Pokemon pokemon;
  final bool selected;
  final VoidCallback onTap;
  const _PokemonTile({
    required this.pokemon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.green.withOpacity(0.12) : null,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(pokemon.imageUrl),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                pokemon.name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            AnimatedScale(
              scale: selected ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 180),
              child: Icon(
                selected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: selected ? Colors.green : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
