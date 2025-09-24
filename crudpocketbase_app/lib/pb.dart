// lib/pb.dart
import 'package:pocketbase/pocketbase.dart';

class PB {
  /// สำหรับทดสอบบน Chrome (Flutter Web)
  static final client = PocketBase('http://127.0.0.1:8090');

  // ถ้าจะไป Android Emulator ในภายหลัง ให้เปลี่ยนเป็น:
  // static final client = PocketBase('http://10.0.2.2:8090');
}
