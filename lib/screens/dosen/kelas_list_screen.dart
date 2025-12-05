import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/dosen_provider.dart';

class DosenKelasListScreen extends ConsumerWidget {
  const DosenKelasListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kelasList = ref.watch(dosenKelasListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelas Saya'),
      ),
      body: kelasList.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(dosenKelasListProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (kelasList) {
          if (kelasList.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.class_, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Belum ada kelas yang diampu'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: kelasList.length,
            itemBuilder: (context, index) {
              final kelas = kelasList[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    child: const Icon(Icons.class_, color: Colors.blue),
                  ),
                  title: Text(
                    kelas.namaKelas,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      if (kelas.namaMatakuliah != null)
                        Text('📚 ${kelas.namaMatakuliah}'),
                      if (kelas.ruangan != null)
                        Text('🏫 Ruangan: ${kelas.ruangan}'),
                      Text('📅 ${kelas.jadwal}'),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/dosen/open-sesi',
                      arguments: kelas,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
