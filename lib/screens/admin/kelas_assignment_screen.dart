import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/admin_service.dart';
import '../../models/kelas_model.dart';
import '../../models/dosen_model.dart';
import '../../models/matakuliah_model.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/modern_card.dart';
import '../../config/app_colors.dart';

class KelasAssignmentScreen extends ConsumerStatefulWidget {
  const KelasAssignmentScreen({super.key});

  @override
  ConsumerState<KelasAssignmentScreen> createState() => _KelasAssignmentScreenState();
}

class _KelasAssignmentScreenState extends ConsumerState<KelasAssignmentScreen> {
  final AdminService _adminService = AdminService();
  
  List<KelasModel> _kelasList = [];
  List<Map<String, dynamic>> _assignments = [];
  List<DosenModel> _dosenList = [];
  List<MataKuliahModel> _matakuliahList = [];
  
  int? _selectedKelasId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final kelas = await _adminService.getAllKelas();
      final dosen = await _adminService.getAllDosen();
      final mk = await _adminService.getAllMataKuliah();
      
      setState(() {
        _kelasList = kelas;
        _dosenList = dosen;
        _matakuliahList = mk;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Gagal memuat data: $e');
    }
  }

  Future<void> _loadAssignments(int idKelas) async {
    setState(() => _isLoading = true);
    try {
      final assignments = await _adminService.getKelasAssignments(idKelas);
      setState(() {
        _assignments = assignments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Gagal memuat jadwal: $e');
    }
  }

  Future<void> _showAddDialog() async {
    String? selectedNip;
    int? selectedMkId;
    String? selectedHari;
    final ruanganController = TextEditingController();
    final jamMulaiController = TextEditingController();
    final jamSelesaiController = TextEditingController();

    final hariList = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Tambah Jadwal Mata Kuliah'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Pilih Dosen
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Pilih Dosen',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedNip,
                      items: _dosenList.map<DropdownMenuItem<String>>((DosenModel dosen) {
                        return DropdownMenuItem<String>(
                          value: dosen.nip,
                          child: Text(dosen.nama),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() => selectedNip = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    // Pilih Mata Kuliah
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Pilih Mata Kuliah',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedMkId,
                      items: _matakuliahList.map<DropdownMenuItem<int>>((MataKuliahModel mk) {
                        return DropdownMenuItem<int>(
                          value: mk.idMatakuliah,
                          child: Text('${mk.kodeMk} - ${mk.namaMatakuliah}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() => selectedMkId = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    // Ruangan
                    TextField(
                      controller: ruanganController,
                      decoration: const InputDecoration(
                        labelText: 'Ruangan',
                        hintText: 'e.g., Lab 301',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Hari
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Hari',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedHari,
                      items: hariList.map((hari) {
                        return DropdownMenuItem(
                          value: hari,
                          child: Text(hari),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() => selectedHari = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    // Jam Mulai
                    TextField(
                      controller: jamMulaiController,
                      decoration: const InputDecoration(
                        labelText: 'Jam Mulai',
                        hintText: 'e.g., 08:00',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Jam Selesai
                    TextField(
                      controller: jamSelesaiController,
                      decoration: const InputDecoration(
                        labelText: 'Jam Selesai',
                        hintText: 'e.g., 10:30',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: selectedNip != null && selectedMkId != null
                      ? () async {
                          Navigator.pop(context);
                          await _addAssignment(
                            selectedNip!,
                            selectedMkId!,
                            ruanganController.text,
                            selectedHari,
                            jamMulaiController.text,
                            jamSelesaiController.text,
                          );
                        }
                      : null,
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _addAssignment(
    String nip,
    int idMatakuliah,
    String? ruangan,
    String? hari,
    String? jamMulai,
    String? jamSelesai,
  ) async {
    if (_selectedKelasId == null) return;

    try {
      final success = await _adminService.assignDosenMatakuliah(
        _selectedKelasId!,
        nip,
        idMatakuliah,
        ruangan: ruangan,
        hari: hari,
        jamMulai: jamMulai,
        jamSelesai: jamSelesai,
      );

      if (success) {
        _showSuccess('Jadwal mata kuliah berhasil ditambahkan');
        await _loadAssignments(_selectedKelasId!);
      }
    } catch (e) {
      _showError('Gagal menambahkan: $e');
    }
  }

  Future<void> _removeAssignment(int idKelasDosen) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Hapus mata kuliah ini dari kelas?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final success = await _adminService.removeKelasDosen(idKelasDosen);
        if (success) {
          _showSuccess('Mata kuliah berhasil dihapus');
          await _loadAssignments(_selectedKelasId!);
        }
      } catch (e) {
        _showError('Gagal menghapus: $e');
      }
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Kelola Jadwal Kelas', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.gradientStart,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GradientBackground(
        child: Column(
          children: [
            // Kelas Selector
            Container(
              padding: const EdgeInsets.all(16),
              child: ModernCard(
                child: DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'Pilih Kelas',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  value: _selectedKelasId,
                  items: _kelasList.map<DropdownMenuItem<int>>((KelasModel kelas) {
                    return DropdownMenuItem<int>(
                      value: kelas.idKelas,
                      child: Text(kelas.namaKelas),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedKelasId = value);
                      _loadAssignments(value);
                    }
                  },
                ),
              ),
            ),

            // Assignments List
            if (_selectedKelasId != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Mata Kuliah yang Dikelola:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: _showAddDialog,
                      icon: const Icon(Icons.add_circle, color: Colors.white),
                      iconSize: 32,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : _assignments.isEmpty
                        ? const Center(
                            child: Text(
                              'Belum ada mata kuliah',
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _assignments.length,
                            itemBuilder: (context, index) {
                              final assignment = _assignments[index];
                              return _buildAssignmentCard(assignment);
                            },
                          ),
              ),
            ] else
              const Expanded(
                child: Center(
                  child: Text(
                    'Pilih kelas untuk mengelola jadwal',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentCard(Map<String, dynamic> assignment) {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    assignment['nama_mk'] ?? 'Mata Kuliah',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dosen: ${assignment['nama_dosen'] ?? '-'}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Kode: ${assignment['kode_mk'] ?? '-'} • ${assignment['sks'] ?? 0} SKS',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (assignment['ruangan'] != null || assignment['hari'] != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${assignment['ruangan'] ?? '-'} • ${assignment['hari'] ?? '-'} ${assignment['jam_mulai'] != null ? '${assignment['jam_mulai']}-${assignment['jam_selesai']}' : ''}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              onPressed: () => _removeAssignment(assignment['id_kelas_dosen']),
              icon: const Icon(Icons.delete, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
