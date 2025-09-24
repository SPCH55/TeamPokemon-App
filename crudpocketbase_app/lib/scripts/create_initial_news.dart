// lib/scripts/create_initial_news.dart

import 'package:pocketbase/pocketbase.dart';
import 'package:flutter/material.dart';
import '../models/news.dart';
import '../services/news_service.dart';

// ฟังก์ชันเพิ่มข้อมูลอัตโนมัติ
Future<void> addInitialNews() async {
  final newsService = NewsService();
  try {
    await newsService.create(
      title: 'ข่าวสารอัปเดต',
      body: 'ข่าวนี้ถูกสร้างอัตโนมัติทุกครั้งที่รันโปรเจค!',
      publishedAt: DateTime.now(),
      publish: true,
    );
    print('ข้อมูลข่าวสารถูกเพิ่มเรียบร้อย');
  } catch (e) {
    print('Error while adding initial news: $e');
  }
}
