import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/team_controller.dart';
import 'team_page.dart';

class TeamsPage extends StatelessWidget {
  const TeamsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TeamController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Teams'),
      ),
      body: Obx(() {
        final list = ctrl.teams;
        if (list.isEmpty) {
          return const Center(child: Text('ยังไม่มีทีม สร้างทีมใหม่ด้วยปุ่ม +'));
        }

        return ListView.separated(
          itemCount: list.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final t = list[i];
            final isCurrent = t.id == ctrl.currentTeamId.value;
            final subtitle = t.members.isEmpty
                ? 'No members'
                : t.members.map((m) => m.name).join(', ');

            return ListTile(
              title: Text(t.name),
              subtitle: Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              leading: CircleAvatar(child: Text('${t.members.length}/3')),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isCurrent)
                    IconButton(
                      tooltip: 'Set Active',
                      icon: const Icon(Icons.check),
                      onPressed: () => ctrl.selectTeam(t.id),
                    ),
                  IconButton(
                    tooltip: 'Rename',
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      final name = await _promptName(context, init: t.name);
                      if (name != null) ctrl.renameTeam(t.id, name);
                    },
                  ),
                  IconButton(
                    tooltip: 'Delete',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _confirmDelete(
                      context,
                      () => ctrl.deleteTeam(t.id),
                    ),
                  ),
                ],
              ),
              onTap: () {
                ctrl.selectTeam(t.id);
                Get.to(() => TeamPage()); // << ไม่มี const
              },
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final name = await _promptName(context, init: 'New Team');
          ctrl.createTeam(name: name ?? 'New Team');
        },
        icon: const Icon(Icons.add),
        label: const Text('New Team'),
      ),
    );
  }

  Future<String?> _promptName(BuildContext context, {required String init}) async {
    final controller = TextEditingController(text: init);
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Team Name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          onSubmitted: (v) => Navigator.pop(context, v),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Save')),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, VoidCallback onOk) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Team?'),
        content: const Text('การลบทีมจะลบสมาชิกในทีมนั้นทั้งหมด'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () { Navigator.pop(context); onOk(); }, child: const Text('Delete')),
        ],
      ),
    );
  }
}
