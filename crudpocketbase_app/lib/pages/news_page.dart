import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/news_service.dart';
import '../models/news.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});
  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final srv = NewsService();
  late Future<List<News>> _future;

  @override
  void initState() {
    super.initState();
    _future = srv.listPublished();
  }

  Future<void> _reload() async {
    setState(() {
      _future = srv.listPublished();
    });
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // -------------------- สร้างข่าว + เลือกรูป --------------------
  Future<void> _createNewsDialog() async {
  final titleCtl = TextEditingController();
  final bodyCtl = TextEditingController();
  bool publish = true;

  Uint8List? pickedBytes;
  String? pickedName;
  String? pickedMime;

  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (ctx, setSB) => AlertDialog(
        title: const Text('สร้างข่าวใหม่'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtl, decoration: const InputDecoration(labelText: 'หัวข้อข่าว')),
              const SizedBox(height: 8),
              TextField(controller: bodyCtl, maxLines: 4, decoration: const InputDecoration(labelText: 'รายละเอียด')),
              const SizedBox(height: 8),

              // ปุ่ม "เลือกรูป"
              Row(
                children: [
                  FilledButton.tonal(
                    onPressed: () async {
                      final res = await FilePicker.platform.pickFiles(
                        type: FileType.image,
                        withData: true, // สำคัญสำหรับเว็บ: เอา bytes มาด้วย
                      );
                      if (res != null && res.files.isNotEmpty) {
                        final f = res.files.first;
                        setSB(() {
                          pickedBytes = f.bytes;
                          pickedName = f.name;
                          pickedMime = null; // อาจเป็น null ได้
                        });
                      }
                    },
                    child: const Text('เลือกรูป'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      pickedName ?? 'ยังไม่เลือกรูป',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: const Text('เผยแพร่เลย'),
                value: publish,
                onChanged: (v) => setSB(() => publish = v ?? true),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ยกเลิก')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('บันทึก')),
        ],
      ),
    ),
  );

  if (ok == true && titleCtl.text.trim().isNotEmpty) {
    try {
      if (pickedBytes != null && pickedName != null) {
        // ส่งรูปภาพไปพร้อมกับข้อมูลข่าว
        await srv.createWithImageBytes(
          title: titleCtl.text.trim(),
          body: bodyCtl.text.trim().isEmpty ? null : bodyCtl.text.trim(),
          publishedAt: DateTime.now(),
          publish: publish,
          imageBytes: pickedBytes!,
          filename: pickedName!,
          contentType: pickedMime,
        );
      } else {
        // สร้างข่าวโดยไม่มีรูป
        await srv.create(
          title: titleCtl.text.trim(),
          body: bodyCtl.text.trim().isEmpty ? null : bodyCtl.text.trim(),
          publishedAt: DateTime.now(),
          publish: publish,
        );
      }
      _toast('สร้างข่าวเรียบร้อย');
      await _reload();
    } catch (e) {
      _toast('ผิดพลาด: $e');
    }
  }
}


  Future<void> _editNewsDialog(News n) async {
    final titleCtl = TextEditingController(text: n.title);
    final bodyCtl = TextEditingController(text: n.body ?? '');
    bool publish = n.isPublished;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('แก้ไขข่าว'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtl, decoration: const InputDecoration(labelText: 'หัวข้อข่าว')),
              const SizedBox(height: 8),
              TextField(controller: bodyCtl, maxLines: 4, decoration: const InputDecoration(labelText: 'รายละเอียด')),
              const SizedBox(height: 8),
              StatefulBuilder(
                builder: (ctx, setSB) => CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('เผยแพร่'),
                  value: publish,
                  onChanged: (v) => setSB(() => publish = v ?? false),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ยกเลิก')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('บันทึก')),
        ],
      ),
    );

    if (ok == true) {
      try {
        await srv.update(
          n.id,
          title: titleCtl.text.trim().isEmpty ? n.title : titleCtl.text.trim(),
          body: bodyCtl.text.trim(),
          publish: publish,
          publishedAt: publish ? (n.publishedAt ?? DateTime.now()) : n.publishedAt,
        );
        _toast('อัปเดตเรียบร้อย');
        await _reload();
      } catch (e) {
        _toast('ผิดพลาด: $e');
      }
    }
  }

  Future<void> _deleteNews(News n) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('ลบข่าวนี้?'),
        content: Text(n.title),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ยกเลิก')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('ลบ')),
        ],
      ),
    );
    if (ok == true) {
      try {
        await srv.delete(n.id);
        _toast('ลบแล้ว');
        await _reload();
      } catch (e) {
        _toast('ผิดพลาด: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ข่าวสาร')),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: FutureBuilder<List<News>>(
          future: _future,
          builder: (ctx, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return ListView(children: [
                const SizedBox(height: 40),
                Center(child: Text('Error: ${snap.error}')),
              ]);
            }
            final items = snap.data ?? [];
            if (items.isEmpty) {
              return ListView(children: const [
                SizedBox(height: 80),
                Center(child: Text('ยังไม่มีข่าว')),
              ]);
            }
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (ctx, i) {
                final n = items[i];
                final img = srv.imageUrl(n);
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // หัวข้อ + ปุ่มแก้ไข/ลบ
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                n.title,
                                style: Theme.of(context).textTheme.titleMedium, // เล็กลง
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              tooltip: 'แก้ไข',
                              onPressed: () => _editNewsDialog(n),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              tooltip: 'ลบ',
                              onPressed: () => _deleteNews(n),
                            ),
                          ],
                        ),
                        // รูปภาพ
                        if (img != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Image.network(img, fit: BoxFit.cover),
                            ),
                          ),
                        if (n.publishedAt != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              'เผยแพร่: ${n.publishedAt}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ),
                        if ((n.body ?? '').isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              (n.body!.length > 160) ? '${n.body!.substring(0, 160)}…' : n.body!,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          n.isPublished ? 'สถานะ: เผยแพร่' : 'สถานะ: ฉบับร่าง',
                          style: TextStyle(
                            color: n.isPublished ? Colors.green[700] : Colors.orange[800],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewsDialog,
        child: const Icon(Icons.add),
        tooltip: 'เพิ่มข่าว',
      ),
    );
  }
}
