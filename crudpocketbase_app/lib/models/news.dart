class News {
  final String id;
  final String title;
  final String? body;
  final String? image;       // file name (not full URL)
  final DateTime? publishedAt;
  final bool isPublished;
  final DateTime? created;
  final DateTime? updated;

  News({
    required this.id,
    required this.title,
    this.body,
    this.image,
    this.publishedAt,
    required this.isPublished,
    this.created,
    this.updated,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    DateTime? parse(String? s) => (s==null||s.isEmpty)? null : DateTime.tryParse(s);
    return News(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'],
      image: json['image'],                // PocketBase เก็บชื่อไฟล์ไว้ที่ฟิลด์นี้
      publishedAt: parse(json['published_at']),
      isPublished: json['is_published'] ?? false,
      created: parse(json['created']),
      updated: parse(json['updated']),
    );
  }
}
