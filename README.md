# CRUD PocketBase App

โปรเจคนี้เป็นแอป **CRUD** ที่สร้างขึ้นโดยใช้ **Flutter** และเชื่อมต่อกับ **PocketBase** เพื่อจัดการข้อมูล ข่าวสารในระบบ แอปนี้รองรับการ **สร้าง, อ่าน, แก้ไข และลบ** ข่าวสาร พร้อมทั้งสามารถอัปโหลดรูปภาพได้

## ฟีเจอร์
- **สร้าง**: เพิ่มข่าวใหม่ที่มีหัวข้อ, เนื้อหา, และรูปภาพ
- **อ่าน**: แสดงรายการข่าวที่เผยแพร่แล้ว
- **แก้ไข**: แก้ไขข่าวที่มีอยู่แล้ว
- **ลบ**: ลบข่าวออกจากระบบ

## เทคโนโลยีที่ใช้
- **Flutter**: ใช้ในการพัฒนาแอปพลิเคชัน
- **PocketBase**: ใช้เป็น Backend สำหรับจัดการข่าวสาร
- **FilePicker**: ใช้สำหรับเลือกไฟล์รูปภาพที่ต้องการอัปโหลด

## วิธีการติดตั้งและรันโปรเจค

### 1. โคลนโปรเจคมาใช้งาน

เริ่มต้นโดยการโคลนโปรเจคนี้ไปยังเครื่องของคุณ:

```bash
git clone https://github.com/SPCH55/TeamPokemon-App.git
cd TeamPokemon-App
```
### 2. ติดตั้ง Dependencies
```bash
flutter pub get
```
### 3. รัน PocketBase บนเครื่องท้องถิ่น
ในการใช้ PocketBase เป็น Backend ของแอป คุณต้องรัน PocketBase บนเครื่องท้องถิ่นก่อน:
* ดาวน์โหลด PocketBase: ไปที่ หน้า Releases ของ PocketBase
 และดาวน์โหลดเวอร์ชันล่าสุด
* แตกไฟล์ PocketBase ที่ดาวน์โหลดมา
* เปิด Terminal หรือ Command Prompt และเข้าไปที่โฟลเดอร์ที่แตกไฟล์ PocketBase
* ใช้คำสั่งนี้เพื่อรัน PocketBase:
```bash
./pocketbase serve  # สำหรับ macOS/Linux
pocketbase serve    # สำหรับ Windows
```

### 4. ตั้งค่าฐานข้อมูลใน PocketBase
1.เข้าสู่ PocketBase Admin Panel ที่ http://127.0.0.1:8090
2.สร้าง Collection ที่ชื่อ news และเพิ่มฟิลด์ดังนี้:
* title (ประเภท Text)
* body (ประเภท Text, อาจเป็น null ได้)
* is_published (ประเภท Boolean)
* published_at (ประเภท DateTime, อาจเป็น null ได้)
* image (ประเภท File, อาจเป็น null ได้)

### 5. รันแอป
```bash
flutter run
```