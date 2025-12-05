import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'models/kelas_model.dart';
import 'models/sesi_model.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/admin/dosen_management_screen.dart';
import 'screens/admin/mahasiswa_management_screen.dart';
import 'screens/admin/matakuliah_management_screen.dart';
import 'screens/admin/kelas_management_screen.dart';
import 'screens/admin/kelas_assignment_screen.dart';
import 'screens/dosen/dosen_dashboard.dart';
import 'screens/dosen/kelas_list_screen.dart';
import 'screens/dosen/kelas_detail_screen.dart';
import 'screens/dosen/dosen_face_registration_screen.dart';
import 'screens/dosen/dosen_face_verify_screen.dart';
import 'screens/dosen/pertemuan_detail_screen.dart';
import 'screens/dosen/open_sesi_screen.dart';
import 'screens/dosen/active_sessions_screen.dart';
import 'screens/mahasiswa/mahasiswa_dashboard.dart';
import 'screens/mahasiswa/face_registration_screen.dart';
import 'screens/mahasiswa/mahasiswa_active_sessions_screen.dart';
import 'screens/mahasiswa/scan_qr_absensi_screen.dart';
import 'screens/mahasiswa/absensi_screen.dart';
import 'screens/mahasiswa/history_screen.dart';
import 'screens/mahasiswa/statistics_screen.dart';
import 'screens/common/profile_screen.dart';
import 'screens/common/edit_profile_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Aplikasi Absensi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/admin': (context) => const AdminDashboard(),
        '/admin/dosen': (context) => const DosenManagementScreen(),
        '/admin/mahasiswa': (context) => const MahasiswaManagementScreen(),
        '/admin/matakuliah': (context) => const MataKuliahManagementScreen(),
        '/admin/kelas': (context) => const KelasManagementScreen(),
        '/admin/kelas-assignment': (context) => const KelasAssignmentScreen(),
        '/dosen': (context) => const DosenDashboard(),
        '/dosen/kelas': (context) => const DosenKelasListScreen(),
        '/dosen/face-registration': (context) => const DosenFaceRegistrationScreen(),
        '/dosen/face-verify': (context) {
          final kelas = ModalRoute.of(context)!.settings.arguments as KelasModel;
          return DosenFaceVerifyScreen(kelas: kelas);
        },
        '/dosen/open-sesi': (context) => const OpenSesiScreen(),
        '/dosen/active-sessions': (context) => const ActiveSessionsScreen(),
        '/dosen/pertemuan-detail': (context) {
          final sesi = ModalRoute.of(context)!.settings.arguments as SesiModel;
          return PertemuanDetailScreen(sesi: sesi);
        },
        '/mahasiswa': (context) => const MahasiswaDashboard(),
        '/mahasiswa/face-registration': (context) => const FaceRegistrationScreen(),
        '/mahasiswa/active-sessions': (context) => const MahasiswaActiveSessionsScreen(),
        '/mahasiswa/scan-qr': (context) => const ScanQRAbsensiScreen(),
        '/mahasiswa/absensi': (context) => const AbsensiScreen(),
        '/mahasiswa/history': (context) => const HistoryScreen(),
        '/mahasiswa/statistics': (context) => const StatisticsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
      },
    );
  }
}
