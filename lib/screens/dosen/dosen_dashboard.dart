import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dosen_provider.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/kelas_card.dart';
import '../../config/app_colors.dart';
import 'kelas_detail_screen.dart';

class DosenDashboard extends ConsumerStatefulWidget {
  const DosenDashboard({super.key});

  @override
  ConsumerState<DosenDashboard> createState() => _DosenDashboardState();
}

class _DosenDashboardState extends ConsumerState<DosenDashboard> {
  @override
  void initState() {
    super.initState();
    // Load kelas saat dashboard dibuka - trigger refresh
    Future.microtask(() => ref.refresh(dosenKelasListProvider));
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).user;
    final kelasAsync = ref.watch(dosenKelasListProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        title: const Text(
          'Halaman Dosen',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.gradientStart,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: _buildDrawer(context, ref, user),
      body: GradientBackground(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: RefreshIndicator(
            onRefresh: () async {
              ref.refresh(dosenKelasListProvider);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Text
                  Text(
                    'Selamat datang, ${user?.nama ?? 'Dosen'}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'NIP: ${user?.nip ?? '-'}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  const Text(
                    'Daftar Pertemuan Anda:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Kelas List with AsyncValue
                  kelasAsync.when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                    error: (error, stack) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            const Icon(Icons.error_outline,
                                size: 48, color: Colors.white70),
                            const SizedBox(height: 16),
                            Text(
                              error.toString(),
                              style: const TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    data: (kelasList) {
                      if (kelasList.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              children: const [
                                Icon(Icons.class_,
                                    size: 48, color: Colors.white70),
                                SizedBox(height: 16),
                                Text(
                                  'Belum ada kelas yang diampu',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: kelasList.map((kelas) {
                          return KelasCard(
                            namaKelas: kelas.namaMatakuliah ?? 'Mata Kuliah',
                            subtitle:
                                '${kelas.hari ?? '-'} / ${kelas.jamMulai ?? '-'} - ${kelas.jamSelesai ?? '-'}',
                            badge: kelas.namaKelas ?? '',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => KelasDetailScreen(kelas: kelas),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
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
                _getInitials(user?.nama ?? 'Dosen'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            accountName: Text(
              user?.nama ?? 'Dosen',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text(
              'NIP: ${user?.nip ?? '-'}',
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

          // Registrasi Wajah Menu Item
          ListTile(
            leading: const Icon(Icons.face, color: AppColors.primary),
            title: const Text('Registrasi Wajah'),
            subtitle: const Text('Daftar wajah untuk verifikasi'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/dosen/face-registration');
            },
          ),

          // Sesi Aktif
          ListTile(
            leading: const Icon(Icons.timelapse, color: AppColors.primary),
            title: const Text('Sesi Aktif'),
            subtitle: const Text('Monitor sesi yang berjalan'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/dosen/active-sessions');
            },
          ),

          // Logout Menu Item
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              Navigator.pop(context);
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
}
