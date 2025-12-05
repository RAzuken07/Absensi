import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/profile_card.dart';
import '../../widgets/modern_card.dart';
import '../../config/app_colors.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        title: const Text(
          'Beranda Admin',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.gradientStart, // Dark blue
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: _buildDrawer(context, ref, user),
      body: GradientBackground(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Menu Title
                const Text(
                  'Menu Admin:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // Menu Cards
                _buildMenuCard(
                  context,
                  'Kelola Dosen',
                  'Tambah / Edit / Hapus Dosen',
                  Icons.person,
                  () => Navigator.pushNamed(context, '/admin/dosen'),
                ),
                _buildMenuCard(
                  context,
                  'Kelola Mahasiswa',
                  'Tambah / Edit / Hapus Mahasiswa',
                  Icons.school,
                  () => Navigator.pushNamed(context, '/admin/mahasiswa'),
                ),
                _buildMenuCard(
                  context,
                  'Management Mata Kuliah',
                  'Kelola Data Mata Kuliah',
                  Icons.book,
                  () => Navigator.pushNamed(context, '/admin/matakuliah'),
                ),
                _buildMenuCard(
                  context,
                  'Laporan Absensi',
                  'Export PDF & Statistik Absensi',
                  Icons.bar_chart,
                  () {
                    // TODO: Navigate to laporan screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fitur Laporan Absensi (Coming Soon)'),
                      ),
                    );
                  },
                ),
                _buildMenuCard(
                  context,
                  'Kelola Jadwal Absensi',
                  'Atur Dosen & Mata Kuliah per Kelas',
                  Icons.schedule,
                  () => Navigator.pushNamed(context, '/admin/kelas-assignment'),
                ),
                _buildMenuCard(
                  context,
                  'Management Kelas',
                  'Buat / Edit / Hapus Jadwal Absensi',
                  Icons.calendar_today,
                  () => Navigator.pushNamed(context, '/admin/kelas'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, WidgetRef ref, dynamic user) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer Header with Profile
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.gradientStart,
                  AppColors.gradientEnd,
                ],
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                _getInitials(user?.nama ?? 'Admin'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            accountName: Text(
              user?.nama ?? 'Administrator',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text(
              '${user?.username ?? 'admin'}@admin.pnl.ac.id',
              style: const TextStyle(fontSize: 14),
            ),
          ),

          // Profile Menu Item
          ListTile(
            leading: const Icon(Icons.person, color: AppColors.primary),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile');
            },
          ),

          const Divider(),

          // Logout Menu Item
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              Navigator.pop(context); // Close drawer
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final words = name.trim().split(' ');
    if (words.isEmpty) return '';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[words.length - 1][0]}'.toUpperCase();
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ModernCard(
      onTap: onTap,
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 32,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Arrow
          const Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
