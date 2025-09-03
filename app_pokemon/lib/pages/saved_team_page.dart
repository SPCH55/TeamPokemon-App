import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/team_controller.dart';
import '../models/pokemon.dart';

class SavedTeamPage extends StatelessWidget {
  const SavedTeamPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TeamController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Team'),
        actions: [
          IconButton(
            tooltip: 'Reset Team',
            onPressed: ctrl.resetTeam,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Obx(() {
        final name = ctrl.teamName.value;
        final members = ctrl.team;

        if (members.isEmpty) {
          return const Center(
            child: Text('ยังไม่มีสมาชิกทีมที่บันทึกไว้'),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // ปรับจำนวนคอลัมน์ตามความกว้างหน้าจอ
                    final width = constraints.maxWidth;
                    int crossAxisCount = 2;
                    if (width > 900) crossAxisCount = 4;
                    else if (width > 600) crossAxisCount = 3;

                    return GridView.builder(
                      itemCount: members.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: 3 / 4,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemBuilder: (_, i) {
                        final Pokemon p = members[i];
                        return _PokemonCard(pokemon: p);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _PokemonCard extends StatelessWidget {
  final Pokemon pokemon;
  const _PokemonCard({required this.pokemon});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: Hero(
                tag: 'poke_${pokemon.id}_saved',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Image.network(
                      pokemon.imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image_not_supported, size: 48),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              pokemon.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
