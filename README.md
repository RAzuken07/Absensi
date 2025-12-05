# Aplikasi Absensi - Face Recognition & QR Code

Sistem manajemen kehadiran berbasis Flutter (mobile) dan Python Flask (backend) dengan teknologi Face Recognition dan QR Code.

## 📁 Struktur Proyek

```
projektaiabsensi/
├── backend/
│   ├── server/               # Python Flask Backend
│   │   ├── app.py           # Main Flask application
│   │   ├── config.py        # Configuration
│   │   ├── requirements.txt # Python dependencies
│   │   ├── database/        # Database connection
│   │   ├── routes/          # API endpoints
│   │   │   ├── auth_routes.py       # Authentication
│   │   │   ├── admin_routes.py      # Admin management
│   │   │   ├── dosen_routes.py      # Lecturer features
│   │   │   ├── face_routes.py       # Face recognition
│   │   │   └── absensi_routes.py    # Attendance
│   │   ├── services/        # Business logic
│   │   └── utils/           # Utilities (JWT, geolocation, QR)
│   └── database/
│       └── add_schedule_columns.sql
├── lib/                      # Flutter Frontend
│   ├── main.dart            # Entry point
│   ├── config/              # App configuration & theme
│   ├── models/              # Data models
│   ├── services/            # API services
│   ├── providers/           # State management (Riverpod)
│   ├── screens/             # UI screens
│   │   ├── auth/           # Login & splash
│   │   ├── admin/          # Admin management screens
│   │   ├── dosen/          # Lecturer screens
│   │   ├── mahasiswa/      # Student screens
│   │   └── common/         # Shared screens (profile, edit)
│   └── widgets/            # Reusable UI components
└── database_absensi.sql    # Database schema
```

## 🔄 Alur Kerja Aplikasi

### 1. **Alur Kerja Admin**

#### A. Manajemen Data Master
1. **Login** sebagai Admin (username: `admin`, password: `123456`)
2. **Dashboard Admin** menampilkan statistik dan menu manajemen
3. **Manajemen Dosen**
   - Tambah/Edit/Hapus data dosen (NIP, Nama, Email, No HP)
4. **Manajemen Mahasiswa**
   - Tambah/Edit/Hapus data mahasiswa (NIM, Nama, Email, No HP, Angkatan)
   - Assign mahasiswa ke kelas
5. **Manajemen Mata Kuliah**
   - Tambah/Edit/Hapus mata kuliah (Kode MK, Nama, SKS, Semester)
   - Assign dosen pengampu
6. **Manajemen Kelas**
   - Tambah/Edit/Hapus kelas (Nama Kelas, Tahun Ajaran, Semester)
   - Hanya mengelola informasi dasar kelas

#### B. Kelola Jadwal Kelas
1. Pilih kelas yang akan dijadwalkan
2. Assign:
   - Mata Kuliah
   - Dosen Pengampu
   - Ruangan
   - Hari
   - Jam Mulai & Jam Selesai
3. Simpan jadwal kelas

### 2. **Alur Kerja Dosen**

#### A. Persiapan Awal
1. **Login** sebagai Dosen (username: `dosen1`, password: `123456`)
2. **Dashboard Dosen** menampilkan:
   - Kelas yang diampu
   - Statistik kehadiran
   - Quick actions

#### B. Registrasi Wajah (Opsional)
1. Masuk ke menu **Registrasi Wajah**
2. Ambil foto wajah menggunakan kamera
3. Upload foto untuk registrasi face recognition
4. Sistem menyimpan face descriptor

#### C. Membuka Sesi Absensi
1. Pilih **Kelas** yang akan dibuka sesinya
2. Pilih **Pertemuan** (atau buat pertemuan baru)
3. Klik **Buka Sesi Absensi**
4. Atur:
   - Durasi sesi (default: 15 menit)
   - Lokasi (Latitude & Longitude dari GPS)
   - Radius toleransi (default: 50 meter)
5. Sistem generate **QR Code** yang berisi:
   - ID Sesi
   - ID Pertemuan
   - Waktu buka
   - Lokasi
6. **Tampilkan QR Code** di layar untuk di-scan mahasiswa

#### D. Monitor Sesi Aktif
1. Lihat daftar **Sesi Aktif**
2. Monitor mahasiswa yang sudah absen real-time
3. Lihat waktu sisa sesi
4. **Tutup Sesi** manual atau otomatis setelah durasi habis

#### E. Rekap Kehadiran
1. Pilih **Kelas**
2. Pilih **Pertemuan**
3. Lihat daftar kehadiran mahasiswa:
   - Status: Hadir, Izin, Sakit, Alpha
   - Waktu absen
   - Confidence score (face recognition)
   - Lokasi absen
4. Export rekap (future feature)

### 3. **Alur Kerja Mahasiswa**

#### A. Persiapan Awal
1. **Login** sebagai Mahasiswa (username: `220101001`, password: `123456`)
2. **Dashboard Mahasiswa** menampilkan:
   - Daftar mata kuliah semester ini
   - Statistik kehadiran per mata kuliah
   - Notifikasi sesi aktif

#### B. Registrasi Wajah (Wajib)
1. Masuk ke menu **Registrasi Wajah**
2. Ambil foto wajah menggunakan kamera dengan panduan:
   - Posisi wajah di tengah frame
   - Pencahayaan cukup
   - Tidak menggunakan masker/kacamata hitam
3. **Capture** foto
4. Preview hasil capture
5. Upload ke server
6. Sistem menyimpan face descriptor untuk verifikasi

#### C. Proses Absensi (Multi-Layer Validation)

**Layer 1: Scan QR Code**
1. Ketika dosen membuka sesi, mahasiswa klik **Absensi**
2. Pilih mata kuliah yang sesinya aktif
3. Klik **Scan QR Code**
4. Arahkan kamera ke QR Code yang ditampilkan dosen
5. Sistem validasi:
   - ✅ QR Code valid & sesi masih aktif
   - ✅ Belum pernah absen di pertemuan ini
   - ✅ Sesi belum expired

**Layer 2: Verifikasi Lokasi (Geolocation)**
1. Sistem otomatis ambil lokasi GPS mahasiswa
2. Validasi jarak antara lokasi mahasiswa dengan lokasi sesi (dari QR)
3. Jika jarak > radius toleransi (50m) → **Ditolak**
4. Jika jarak ≤ radius → **Lanjut ke Layer 3**

**Layer 3: Capture & Verifikasi Wajah**
1. Setelah QR & lokasi valid, muncul **kamera face capture**
2. Ambil foto wajah real-time
3. Preview hasil capture
4. Konfirmasi foto

**Layer 4: Submit Absensi**
1. Sistem kirim data ke backend:
   - ID Sesi
   - NIM
   - Face image (base64)
   - Lokasi (lat, long)
2. Backend verifikasi wajah dengan face descriptor mahasiswa
3. Hitung confidence score
4. Jika confidence ≥ threshold (default 0.6) → **Absensi Berhasil**
5. Jika confidence < threshold → **Ditolak**

**Multi-Layer Summary:**
```
QR Code Scan → Validasi Lokasi → Face Capture → Face Verification → Submit Absensi
     ✓              ✓                  ✓              ✓                  ✓
```

#### D. Melihat History & Statistik
1. **History Kehadiran**:
   - Daftar semua absensi yang pernah dilakukan
   - Filter per mata kuliah
   - Detail waktu, status, lokasi
2. **Statistik Kehadiran**:
   - Persentase kehadiran per mata kuliah
   - Total: Hadir, Izin, Sakit, Alpha
   - Chart/grafik kehadiran

## 🚀 Cara Menjalankan

### Backend (Python Flask)

1. **Setup Database**
   ```bash
   # Import database schema
   mysql -u root -p < database_absensi.sql
   
   # (Optional) Update schema dengan kolom jadwal
   mysql -u root -p absensi < backend/database/add_schedule_columns.sql
   ```

2. **Install Dependencies**
   ```bash
   cd backend/server
   pip install -r requirements.txt
   ```

3. **Konfigurasi Database**
   
   Edit `backend/server/config.py`:
   ```python
   DB_HOST = 'localhost'
   DB_USER = 'root'
   DB_PASSWORD = ''  # Password MySQL Anda
   DB_NAME = 'absensi'
   ```

4. **Run Server**
   ```bash
   python app.py
   ```
   
   Server berjalan di `http://localhost:5000`

### Frontend (Flutter)

1. **Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **Konfigurasi API**
   
   Edit `lib/config/constants.dart`:
   ```dart
   // Untuk emulator Android
   static const String baseUrl = 'http://10.0.2.2:5000';
   
   // Untuk device fisik di network yang sama
   // static const String baseUrl = 'http://192.168.x.x:5000';
   ```

3. **Run App**
   ```bash
   flutter run
   ```

## 👤 Login Credentials

**Admin:**
- Username: `admin`
- Password: `123456`

**Dosen:**
- Username: `dosen1`
- Password: `123456`
- Username: `dosen2`
- Password: `123456`

**Mahasiswa:**
- Username: `220101001` (Andi Pratama - TIF-3A)
- Password: `123456`
- Username: `220101002` (Budi Setiawan - TIF-3A)
- Password: `123456`

## 🌟 Fitur yang Sudah Selesai

### ✅ Backend (Python Flask)
- [x] Authentication dengan JWT
- [x] API Admin CRUD (Dosen, Mahasiswa, Mata Kuliah, Kelas)
- [x] API Kelola Jadwal Kelas (assign dosen, mata kuliah, jadwal)
- [x] API Dosen (Kelas, Pertemuan, Sesi Absensi)
- [x] API Mahasiswa (Daftar mata kuliah, active sessions, history, statistics)
- [x] Face Recognition API (register & verify)
- [x] QR Code Generation untuk sesi
- [x] Geolocation validation
- [x] Database schema dengan views & triggers
- [x] Multi-layer validation (QR + Location + Face + Time)

### ✅ Frontend (Flutter)
- [x] Authentication & Authorization
- [x] Admin Dashboard
- [x] Manajemen Dosen (CRUD)
- [x] Manajemen Mahasiswa (CRUD)
- [x] Manajemen Mata Kuliah (CRUD)
- [x] Manajemen Kelas (CRUD)
- [x] Kelola Jadwal Kelas (assign dosen, MK, ruangan, hari, jam)
- [x] Dosen Dashboard
- [x] Dosen Kelas List & Detail
- [x] Open Sesi Absensi dengan QR Code
- [x] Close Sesi Absensi
- [x] Monitor Active Sessions
- [x] Rekap Kehadiran per Pertemuan
- [x] Mahasiswa Dashboard
- [x] Daftar Mata Kuliah Mahasiswa
- [x] Face Registration untuk Mahasiswa
- [x] QR Scanner untuk Absensi
- [x] Face Capture & Verification
- [x] Validasi Geolocation
- [x] History Kehadiran
- [x] Statistics Kehadiran
- [x] Profile & Edit Profile Screen
- [x] Modern UI dengan Material 3 Design
- [x] Gradient backgrounds & custom widgets

## ⚠️ Fitur yang Belum Selesai / Perlu Perbaikan

### 🔧 Backend

1. **Face Recognition Implementation**
   - ❌ **Implementasi algoritma face recognition yang sebenarnya**
     - Location: `backend/server/routes/dosen_routes.py:220`, `backend/server/routes/absensi_routes.py:248`
     - Status: Masih menggunakan placeholder/mock verification
     - TODO: Implementasikan actual face comparison menggunakan library seperti `face_recognition`, `dlib`, atau `opencv`
     - Perlu: Training model atau menggunakan pre-trained model untuk face embedding

2. **Password Hashing**
   - ⚠️ Password masih tersimpan dalam **plain text** di database
   - Perlu: Implementasi bcrypt/argon2 untuk hashing password
   - Security risk: High priority

### � Frontend

3. **QR Code Session Validation API**
   - ❌ **API call untuk validasi sesi setelah scan QR**
     - Location: `lib/screens/mahasiswa/scan_qr_absensi_screen.dart:84`
     - Status: Comment "// TODO: Call API to validate session"
     - Perlu: Implementasi API call untuk validasi QR data dengan backend

4. **Pertemuan Detail API**
   - ❌ **API call untuk load detail pertemuan**
     - Location: `lib/screens/dosen/pertemuan_detail_screen.dart:40`
     - Status: Comment "// TODO: Replace with actual API call"
     - Perlu: Fetch data kehadiran mahasiswa untuk pertemuan tertentu

5. **Edit Profile API**
   - ❌ **API call untuk update profile user**
     - Location: `lib/screens/common/edit_profile_screen.dart:39`
     - Status: Comment "// TODO: Implement API call to update profile"
     - Perlu: Backend endpoint untuk update user profile

6. **Laporan/Report Screen**
   - ❌ **Screen untuk generate laporan kehadiran**
     - Location: `lib/screens/admin/admin_dashboard.dart:77`
     - Status: Comment "// TODO: Navigate to laporan screen"
     - Perlu: 
       - Buat screen baru untuk laporan
       - Backend API untuk generate report (PDF/Excel)
       - Filter laporan (per kelas, per mata kuliah, per periode)

7. **Face Verification di Kelas Detail (Dosen)**
   - ⚠️ **Feature face verification untuk dosen dihapus sementara**
     - Location: `lib/screens/dosen/kelas_detail_screen.dart:116`
     - Status: Comment "// TODO: Add face verification back later"
     - Perlu: Re-implementasi jika diperlukan

### 🔧 Features Enhancement

8. **Notifikasi Push**
   - ❌ Belum ada sistem notifikasi push
   - Perlu: Firebase Cloud Messaging (FCM) integration
   - Use case: Notif ketika sesi dibuka, reminder absen, dll.

9. **Refresh Token Mechanism**
   - ❌ Belum ada auto-refresh token
   - Perlu: Implementasi refresh token untuk extend session
   - Current: Token expire dan user harus login ulang

10. **Export Laporan**
    - ❌ Belum bisa export rekap kehadiran ke Excel/PDF
    - Perlu: Backend endpoint untuk generate file
    - Format: Excel (.xlsx) atau PDF

11. **Manual Attendance Entry**
    - ❌ Belum ada fitur input kehadiran manual oleh dosen
    - Use case: Jika mahasiswa lupa/tidak bisa absen, dosen bisa input manual
    - Perlu: Form input manual dengan status (Izin, Sakit)

12. **Camera Permission Handling**
    - ⚠️ Handling permission camera & location masih minimal
    - Perlu: Better error message dan guidance jika permission ditolak

13. **Offline Mode**
    - ❌ Belum ada offline support
    - Perlu: Cache data dengan SQLite lokal
    - Use case: Lihat history ketika tidak ada internet

14. **Image Compression**
    - ⚠️ Image face upload belum terkompresi
    - Perlu: Compress image sebelum upload untuk hemat bandwidth
    - Library: `flutter_image_compress`

15. **Testing**
    - ❌ Belum ada unit tests
    - ❌ Belum ada integration tests
    - ❌ Belum ada widget tests
    - Perlu: Comprehensive testing suite

## 🔒 Multi-Layer Validation

Sistem absensi menggunakan 4 layer validasi untuk mencegah kecurangan:

1. **QR Code** - Validasi sesi yang benar & masih aktif
2. **Geolocation** - Memastikan mahasiswa berada di lokasi kampus (radius 50m)
3. **Face Recognition** - Verifikasi identitas mahasiswa dengan AI
4. **Time Window** - Sesi hanya aktif dalam durasi tertentu (default 15 menit)

## 🛠️ Technology Stack

**Backend:**
- Python 3.10+
- Flask (REST API)
- MySQL (Database)
- PyMySQL (Database connector)
- JWT (Authentication)
- Face Recognition Library (`face_recognition` - need implementation)
- QR Code Generation
- Geolocation calculation

**Frontend:**
- Flutter 3.x
- Dart
- Riverpod (State Management)
- Dio (HTTP Client)
- Camera Plugin
- Mobile Scanner (QR Scanner)
- Geolocator (GPS)
- Material 3 Design

## 📝 API Endpoints

Dokumentasi singkat API:

### Auth
- `POST /auth/login` - Login dengan username & password

### Admin
- `GET /admin/dosen` - Get all dosen
- `POST /admin/dosen` - Create dosen
- `PUT /admin/dosen/<nip>` - Update dosen
- `DELETE /admin/dosen/<nip>` - Delete dosen
- `GET /admin/mahasiswa` - Get all mahasiswa
- `POST /admin/mahasiswa` - Create mahasiswa
- `PUT /admin/mahasiswa/<nim>` - Update mahasiswa
- `DELETE /admin/mahasiswa/<nim>` - Delete mahasiswa
- `GET /admin/matakuliah` - Get all mata kuliah
- `POST /admin/matakuliah` - Create mata kuliah
- `PUT /admin/matakuliah/<id>` - Update mata kuliah
- `DELETE /admin/matakuliah/<id>` - Delete mata kuliah
- `GET /admin/kelas` - Get all kelas
- `POST /admin/kelas` - Create kelas
- `PUT /admin/kelas/<id>` - Update kelas & schedule
- `DELETE /admin/kelas/<id>` - Delete kelas

### Dosen
- `GET /dosen/kelas` - Get kelas yang diampu
- `GET /dosen/kelas/<id>` - Get detail kelas
- `POST /dosen/sesi` - Open sesi absensi
- `PUT /dosen/sesi/<id>/close` - Close sesi
- `GET /dosen/active-sessions` - Get active sessions
- `GET /dosen/rekap/<id_pertemuan>` - Get rekap kehadiran

### Mahasiswa (Absensi)
- `GET /absensi/my-matakuliah` - Get mata kuliah mahasiswa
- `GET /absensi/active-sessions` - Get active sessions
- `POST /absensi/submit` - Submit absensi
- `GET /absensi/history` - Get history kehadiran
- `GET /absensi/statistics` - Get statistics kehadiran
- `POST /absensi/register-face` - Register face
- `POST /absensi/verify-face` - Verify face

### Face Recognition
- `POST /face/register` - Register face (mahasiswa/dosen)
- `POST /face/verify` - Verify face
- `GET /face/status/<nim>` - Check registration status

## � Database Schema

Database menggunakan MySQL dengan beberapa tabel utama:
- `users` - Authentication table
- `dosen` - Lecturer data
- `mahasiswa` - Student data
- `matakuliah` - Course data
- `kelas` - Class data (dengan kolom: ruangan, hari, jam_mulai, jam_selesai)
- `pertemuan` - Meeting/session data
- `sesi_absensi` - Attendance session
- `absensi` - Attendance records
- `barcode` - QR code data
- `face_scan_log` - Face recognition logs
- `notifikasi` - Notifications

**Views:**
- `v_sesi_aktif` - View active sessions dengan detail lengkap
- `v_rekap_kehadiran` - View rekap kehadiran mahasiswa

**Triggers:**
- Automatic notification ketika sesi dibuka
- Face registration logging

## 🎨 UI/UX Design

- Modern Material 3 Design
- Gradient backgrounds untuk visual appeal
- Custom widgets (ModernCard, GradientBackground)
- Responsive layout
- Dark mode support (theme ready)
- Smooth animations & transitions

## 🔐 Security Features

- JWT token-based authentication
- Role-based access control (Admin, Dosen, Mahasiswa)
- Face recognition untuk anti-spoofing
- Geolocation validation untuk anti-proxy
- QR code dengan expiration time
- SQL injection protection (parameterized queries)

## 📱 Testing Credentials Lengkap

| Role | Username | Password | Kelas | Mata Kuliah |
|------|----------|----------|-------|-------------|
| Admin | admin | 123456 | - | - |
| Dosen | dosen1 | 123456 | TIF-3A | Pemrograman Web |
| Dosen | dosen2 | 123456 | TIF-3B | Basis Data |
| Mahasiswa | 220101001 | 123456 | TIF-3A | Pemrograman Web |
| Mahasiswa | 220101002 | 123456 | TIF-3A | Pemrograman Web |
| Mahasiswa | 220101003 | 123456 | TIF-3A | Pemrograman Web |
| Mahasiswa | 220101004 | 123456 | TIF-3B | Basis Data |

## 🚧 Roadmap & Future Development

**Priority 1 (High):**
1. ✅ Implementasi actual face recognition algorithm
2. ✅ Password hashing untuk security
3. ✅ Complete QR validation API
4. ✅ Pertemuan detail API implementation

**Priority 2 (Medium):**
5. Push notification system
6. Export laporan (Excel/PDF)
7. Manual attendance entry
8. Refresh token mechanism
9. Edit profile API

**Priority 3 (Low):**
10. Offline mode support
11. Image compression
12. Unit & integration tests
13. Performance optimization
14. Admin laporan dashboard

## 📞 Support

Untuk development lanjutan atau troubleshooting:
1. Check console logs untuk error details
2. Verify database connection
3. Ensure camera & location permissions granted
4. Check network connectivity

## 📄 License

Project ini dibuat untuk keperluan edukasi dan pembelajaran.

---

**Last Updated:** December 2025  
**Version:** 1.0.0  
**Status:** Development - MVP Complete, Enhancement in Progress
