import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/sesi_model.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/modern_card.dart';
import '../../widgets/status_badge.dart';
import '../../config/app_colors.dart';

class PertemuanDetailScreen extends ConsumerStatefulWidget {
  final SesiModel sesi;

  const PertemuanDetailScreen({super.key, required this.sesi});

  @override
  ConsumerState<PertemuanDetailScreen> createState() =>
      _PertemuanDetailScreenState();
}

class _PertemuanDetailScreenState
    extends ConsumerState<PertemuanDetailScreen> {
  List<Map<String, dynamic>> _mahasiswaList = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadMahasiswaList();
  }

  Future<void> _loadMahasiswaList() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // TODO: Replace with actual API call
      // final result = await dosenService.getSesiMahasiswa(widget.sesi.idSesi);
      
      // Dummy data for now
      await Future.delayed(const Duration(milliseconds: 500));
      _mahasiswaList = _getDummyMahasiswaList();
      
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getDummyMahasiswaList() {
    return [
      {
        'nim': '2141720001',
        'nama': 'Ahmad Rizki',
        'status': 'hadir',
        'waktu_absen': '07:15:23',
      },
      {
        'nim': '2141720002',
        'nama': 'Siti Nur Azizah',
        'status': 'hadir',
        'waktu_absen': '07:16:45',
      },
      {
        'nim': '2141720003',
        'nama': 'Budi Santoso',
        'status': 'terlambat',
        'waktu_absen': '07:45:12',
      },
      {
        'nim': '2141720004',
        'nama': 'Dewi Lestari',
        'status': 'alpha',
        'waktu_absen': null,
      },
      {
        'nim': '2141720005',
        'nama': 'Eko Prasetyo',
        'status': 'izin',
        'waktu_absen': null,
      },
      {
        'nim': '2141720006',
        'nama': 'Fitri Handayani',
        'status': 'sakit',
        'waktu_absen': null,
      },
    ];
  }

  List<Map<String, dynamic>> get _filteredMahasiswaList {
    if (_searchQuery.isEmpty) return _mahasiswaList;
    
    return _mahasiswaList.where((mhs) {
      final nama = mhs['nama'].toString().toLowerCase();
      final nim = mhs['nim'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return nama.contains(query) || nim.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final timeFormat = DateFormat('HH:mm');
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Detail Pertemuan',
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sesi Info Card
                ModernCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.sesi.namaMatakuliah ?? 'Mata Kuliah',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        Icons.class_,
                        'Kelas',
                        widget.sesi.namaKelas ?? '-',
                      ),
                      _buildInfoRow(
                        Icons.numbers,
                        'Pertemuan',
                        'Pertemuan ke-${widget.sesi.pertemuanKe ?? '-'}',
                      ),
                      _buildInfoRow(
                        Icons.topic,
                        'Topik',
                        widget.sesi.topik ?? '-',
                      ),
                      _buildInfoRow(
                        Icons.calendar_today,
                        'Tanggal',
                        dateFormat.format(widget.sesi.waktuBuka),
                      ),
                      _buildInfoRow(
                        Icons.access_time,
                        'Waktu',
                        timeFormat.format(widget.sesi.waktuBuka),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Search Bar
                ModernCard(
                  child: TextField(
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari mahasiswa (nama/NIM)...',
                      prefixIcon: const Icon(Icons.search),
                      border: InputBorder.none,
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Mahasiswa List Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Daftar Kehadiran Mahasiswa',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_filteredMahasiswaList.length} Mahasiswa',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Mahasiswa List
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  )
                else if (_error != null)
                  ModernCard(
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(Icons.error_outline,
                              size: 48, color: Colors.red),
                          const SizedBox(height: 8),
                          Text('Error: $_error'),
                        ],
                      ),
                    ),
                  )
                else if (_filteredMahasiswaList.isEmpty)
                  ModernCard(
                    child: Center(
                      child: Column(
                        children: const [
                          Icon(Icons.search_off,
                              size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Tidak ada mahasiswa ditemukan'),
                        ],
                      ),
                    ),
                  )
                else
                  ..._filteredMahasiswaList.map((mhs) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildMahasiswaCard(mhs),
                    );
                  }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMahasiswaCard(Map<String, dynamic> mhs) {
    final status = mhs['status'] as String;
    final waktuAbsen = mhs['waktu_absen'] as String?;

    return ModernCard(
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              _getInitials(mhs['nama']),
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mhs['nama'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  mhs['nim'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (waktuAbsen != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        waktuAbsen,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          // Status Badge
          StatusBadge(
            status: status,
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

  String _getStatusLabel(String status) {
    switch (status) {
      case 'hadir':
        return 'Hadir';
      case 'alpha':
        return 'Alpha';
      case 'izin':
        return 'Izin';
      case 'sakit':
        return 'Sakit';
      case 'terlambat':
        return 'Terlambat';
      default:
        return status;
    }
  }
}
