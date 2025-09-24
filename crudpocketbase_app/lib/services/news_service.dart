import 'dart:typed_data';
import 'package:pocketbase/pocketbase.dart';
import 'package:http/http.dart' as http;
import '../pb.dart';
import '../models/news.dart';
import 'package:http_parser/http_parser.dart';

class NewsService {
  final _col = PB.client.collection('news');

  Future<List<News>> listPublished({int perPage = 50}) async {
    final result = await _col.getList(
      page: 1,
      perPage: perPage,
      filter: 'is_published = true',
      sort: '-published_at,-created',
    );
    return result.items.map((r) => News.fromJson(r.toJson())).toList();
  }

  Future<News> create({
    required String title,
    String? body,
    DateTime? publishedAt,
    bool publish = false,
  }) async {
    final rec = await _col.create(body: {
      'title': title,
      'body': body,
      'is_published': publish,
      'published_at': publishedAt?.toIso8601String(),
    });
    return News.fromJson(rec.toJson());
  }

  // ---------- สร้างข่าวพร้อมอัปโหลดรูป (รองรับเว็บ) ----------
  Future<News> createWithImageBytes({
    required String title,
    String? body,
    DateTime? publishedAt,
    bool publish = false,
    required Uint8List imageBytes,
    required String filename,           // เช่น 'cover.jpg'
    String? contentType,                // เช่น 'image/jpeg'
  }) async {
    final file = http.MultipartFile.fromBytes(
      'image',
      imageBytes,
      filename: filename,
      contentType: contentType != null ? MediaTypeHelper(contentType) : null,
    );
    final rec = await _col.create(
      body: {
        'title': title,
        'body': body,
        'is_published': publish,
        'published_at': publishedAt?.toIso8601String(),
      },
      files: [file],
    );
    return News.fromJson(rec.toJson());
  }

  Future<News> update(
    String id, {
    String? title,
    String? body,
    bool? publish,
    DateTime? publishedAt,
  }) async {
    final map = <String, dynamic>{};
    if (title != null) map['title'] = title;
    if (body != null) map['body'] = body;
    if (publish != null) map['is_published'] = publish;
    if (publishedAt != null) map['published_at'] = publishedAt.toIso8601String();
    final rec = await _col.update(id, body: map);
    return News.fromJson(rec.toJson());
  }

  Future<void> delete(String id) async => _col.delete(id);

  // ---------- อัปเดตรูปด้วย bytes (รองรับเว็บ) ----------
  Future<void> updateImageBytes({
    required String id,
    required Uint8List imageBytes,
    required String filename,
    String? contentType,
  }) async {
    final file = http.MultipartFile.fromBytes(
      'image',
      imageBytes,
      filename: filename,
      contentType: contentType != null ? MediaTypeHelper(contentType) : null,
    );
    await _col.update(id, files: [file]);
  }

  String? imageUrl(News n) {
  if (n.image == null || n.image!.isEmpty) return null;
  // URL ของไฟล์ที่เก็บอยู่ใน PocketBase
  return '${PB.client.baseUrl}/api/files/news/${n.id}/${n.image}';
  }
}

/// helper เล็ก ๆ เพื่อแปลง string -> MediaType ของ http

MediaType? MediaTypeHelper(String value) {
  try {
    final parts = value.split('/');
    if (parts.length == 2) return MediaType(parts[0], parts[1]);
  } catch (_) {}
  return null;
}
