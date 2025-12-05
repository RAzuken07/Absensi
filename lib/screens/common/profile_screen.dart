import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/modern_card.dart';
import '../../config/app_colors.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  String _getInitials(String name) {
    final words = name.trim().split(' ');
    if (words.isEmpty) return '';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[words.length - 1][0]}'.toUpperCase();
  }

  String _getRoleText(dynamic user) {
    if (user?.isAdmin == true) return 'Administrator';
    if (user?.isDosen == true) return 'Dosen';
    if (user?.isMahasiswa == true) return 'Mahasiswa';
    return 'User';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.gradientStart,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GradientBackground(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Avatar Section
                ModernCard(
                  child: Column(
                    children: [
                      // Large Avatar
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: AppColors.primary.withOpacity(0.2),
                        child: Text(
                          _getInitials(user?.nama ?? 'User'),
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Name
                      Text(
                        user?.nama ?? 'User',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      
                      // Role Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getRoleText(user),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),

                // Biodata Section
                ModernCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informasi Pribadi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      
                      // Nama Lengkap
                      _buildInfoRow(
                        icon: Icons.person,
                        label: 'Nama Lengkap',
                        value: user?.nama ?? '-',
                      ),
                      const Divider(),
                      
                      // Username
                      _buildInfoRow(
                        icon: Icons.account_circle,
                        label: 'Username',
                        value: user?.username ?? '-',
                      ),
                      const Divider(),
                      
                      // NIP/NIM
                      if (user?.nip != null)
                        _buildInfoRow(
                          icon: Icons.badge,
                          label: 'NIP',
                          value: user?.nip ?? '-',
                        ),
                      if (user?.nim != null)
                        _buildInfoRow(
                          icon: Icons.badge,
                          label: 'NIM',
                          value: user?.nim ?? '-',
                        ),
                      if (user?.nip != null || user?.nim != null)
                        const Divider(),
                      
                      // Email
                      _buildInfoRow(
                        icon: Icons.email,
                        label: 'Email',
                        value: '${user?.username ?? 'user'}@pnl.ac.id',
                        isLast: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Action Button - Edit Profile Only
                ModernCard(
                  child: ListTile(
                    leading: const Icon(
                      Icons.edit,
                      color: AppColors.primary,
                    ),
                    title: const Text('Edit Profile'),
                    subtitle: const Text('Update informasi pribadi'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pushNamed(context, '/edit-profile');
                    },
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Info Text
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'Untuk mengubah username atau password, hubungi administrator.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
