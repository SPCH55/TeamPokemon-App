# TeamPokemon-App

แอปพลิเคชัน Flutter สำหรับจัดการทีมโปเกมอน  
พัฒนาเพื่อฝึกฝนการใช้งาน Flutter + GetX

---

## 📝 ข้อกำหนดของระบบ (Requirements)

- [Flutter SDK](https://docs.flutter.dev/get-started/install) เวอร์ชัน 3.0 ขึ้นไป  
- Dart SDK (มาพร้อม Flutter)  
- Android Studio / VS Code (พร้อม Flutter & Dart plugin)  
- Git (สำหรับ clone repository)  
- Emulator หรืออุปกรณ์จริง (Android/iOS)

---

## 🚀 วิธีการรันโปรเจค (Getting Started)

1. **Clone โปรเจค**
   git clone https://github.com/SPCH55/TeamPokemon-App.git
   cd TeamPokemon-App

2. **ติดตั้ง dependencies**
    flutter pub get

3. **ตรวจสอบการติดตั้ง Flutter**
    flutter doctor

4. **รันโปรเจคบน Emulator หรือ Device จริงs**
    flutter run

---

**โครงสร้างไฟล์หลัก**
    lib/
    ├─ controllers/    # จัดการ state และ logic (GetX)
    ├─ models/         # เก็บโครงสร้างข้อมูล
    ├─ pages/          # หน้าจอ UI
    └─ main.dart       # จุดเริ่มต้นของแอป

---

**ฟีเจอร์ (Features)**
- แสดงทีมโปเกมอนทั้งหมด
- เพิ่ม/แก้ไข/ลบ ทีมโปเกมอน
- จัดการ state ด้วย GetX
