import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_provider.dart';
import '../../models/mahasiswa_model.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/modern_card.dart';
import '../../config/app_colors.dart';

class MahasiswaManagementScreen extends ConsumerWidget {
  const MahasiswaManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mahasiswaList = ref.watch(mahasiswaListProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Manajemen Mahasiswa',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.gradientStart,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showMahasiswaForm(context, ref, null),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Mahasiswa'),
        backgroundColor: AppColors.primary,
      ),
      body: GradientBackground(
        child: mahasiswaList.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.white70),
                const SizedBox(height: 16),
                Text(
                  'Error: $error',
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(mahasiswaListProvider),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
          data: (mahasiswaList) {
            if (mahasiswaList.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: 80,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Belum ada data mahasiswa',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tap tombol + untuk menambah mahasiswa',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: mahasiswaList.length,
              itemBuilder: (context, index) {
                final mahasiswa = mahasiswaList[index];
                return ModernCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Avatar Icon
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.school,
                            size: 32,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Mahasiswa Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mahasiswa.nama,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'NIM: ${mahasiswa.nim}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              if (mahasiswa.namaKelas != null) ...[
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    mahasiswa.namaKelas!,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                              if (mahasiswa.angkatan != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  'Angkatan ${mahasiswa.angkatan}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        // Popup Menu Button
                        PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 20),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, size: 20, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Hapus', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showMahasiswaForm(context, ref, mahasiswa);
                            } else if (value == 'delete') {
                              _confirmDelete(context, ref, mahasiswa);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showMahasiswaForm(
      BuildContext context, WidgetRef ref, MahasiswaModel? mahasiswa) {
    final nimController = TextEditingController(text: mahasiswa?.nim ?? '');
    final namaController = TextEditingController(text: mahasiswa?.nama ?? '');
    final emailController = TextEditingController(text: mahasiswa?.email ?? '');
    final noHpController = TextEditingController(text: mahasiswa?.noHp ?? '');
    final angkatanController =
        TextEditingController(text: mahasiswa?.angkatan ?? '');
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    int? selectedKelasId = mahasiswa?.idKelas;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            mahasiswa == null ? 'Tambah Mahasiswa' : 'Edit Mahasiswa',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Data Mahasiswa Section
                  const Text(
                    'Data Mahasiswa',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: nimController,
                    decoration: const InputDecoration(
                      labelText: 'NIM',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.badge),
                    ),
                    enabled: mahasiswa == null,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'NIM wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: namaController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Nama wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: noHpController,
                    decoration: const InputDecoration(
                      labelText: 'No. HP',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: angkatanController,
                    decoration: const InputDecoration(
                      labelText: 'Angkatan',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Consumer(
                    builder: (context, ref, child) {
                      final kelas = ref.watch(kelasListProvider);
                      return kelas.when(
                        loading: () => const CircularProgressIndicator(),
                        error: (_, __) => const Text('Error loading kelas'),
                        data: (kelasList) => DropdownButtonFormField<int>(
                          value: selectedKelasId,
                          decoration: const InputDecoration(
                            labelText: 'Kelas',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.class_),
                          ),
                          items: kelasList.map((kelas) {
                            return DropdownMenuItem(
                              value: kelas.idKelas,
                              child: Text(kelas.namaKelas),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => selectedKelasId = value);
                          },
                        ),
                      );
                    },
                  ),
                  // Login Account Section (only for new mahasiswa)
                  if (mahasiswa == null) ...[
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    const Text(
                      'Akun Login',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.account_circle),
                      ),
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Username wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Password wajib diisi'
                          : null,
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final data = {
                    'nim': nimController.text,
                    'nama': namaController.text,
                    'email': emailController.text,
                    'no_hp': noHpController.text,
                    'angkatan': angkatanController.text,
                    'id_kelas': selectedKelasId,
                    if (mahasiswa == null) ...{
                      'username': usernameController.text,
                      'password': passwordController.text,
                    },
                  };

                  bool success;
                  if (mahasiswa == null) {
                    success = await ref
                        .read(mahasiswaListProvider.notifier)
                        .createMahasiswa(data);
                  } else {
                    success = await ref
                        .read(mahasiswaListProvider.notifier)
                        .updateMahasiswa(mahasiswa.nim, data);
                  }

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success
                            ? 'Berhasil menyimpan data'
                            : 'Gagal menyimpan data'),
                        backgroundColor: success ? Colors.green : Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, MahasiswaModel mahasiswa) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Hapus Mahasiswa',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('Yakin ingin menghapus ${mahasiswa.nama}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final success = await ref
                  .read(mahasiswaListProvider.notifier)
                  .deleteMahasiswa(mahasiswa.nim);

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Berhasil menghapus data'
                        : 'Gagal menghapus data'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
