import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/kelas_model.dart';
import '../../services/dosen_service.dart';
import '../../widgets/gradient_background.dart';
import '../../config/app_colors.dart';

class RekapKehadiranScreen extends ConsumerStatefulWidget {
  final KelasModel kelas;

  const RekapKehadiranScreen({super.key, required this.kelas});

  @override
  ConsumerState<RekapKehadiranScreen> createState() => _RekapKehadiranScreenState();
}

class _RekapKehadiranScreenState extends ConsumerState<RekapKehadiranScreen> {
  final DosenService _dosenService = DosenService();
  List<Map<String, dynamic>> _pertemuanList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPertemuan();
  }

  Future<void> _loadPertemuan() async {
    setState(() => _isLoading = true);
    try {
      final data = await _dosenService.getPertemuanByKelas(widget.kelas.idKelas);
      if (mounted) {
        setState(() {
          _pertemuanList = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Rekap Kehadiran', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.gradientStart,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GradientBackground(
        child: Column(
          children: [
            // Kelas Info
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.kelas.namaMatakuliah ?? 'Mata Kuliah',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kelas: ${widget.kelas.namaKelas}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Pertemuan List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : _pertemuanList.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.event_busy, size: 64, color: Colors.white70),
                              SizedBox(height: 16),
                              Text(
                                'Belum ada pertemuan',
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _pertemuanList.length,
                          itemBuilder: (context, index) {
                            final pertemuan = _pertemuanList[index];
                            return _buildPertemuanCard(pertemuan);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPertemuanCard(Map<String, dynamic> pertemuan) {
    final pertemuanKe = pertemuan['pertemuan_ke'] ?? 0;
    final topik = pertemuan['topik'] ?? 'Pertemuan $pertemuanKe';
    final tanggal = pertemuan['tanggal'];
    
    String formattedDate = '-';
    if (tanggal != null) {
      try {
        final date = tanggal is DateTime ? tanggal : DateTime.parse(tanggal.toString());
        formattedDate = DateFormat('dd MMM yyyy').format(date);
      } catch (e) {
        formattedDate = tanggal.toString();
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailAbsensiPertemuanScreen(
                  kelas: widget.kelas,
                  pertemuan: pertemuan,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '$pertemuanKe',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topik,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Detail Absensi Per Pertemuan Screen
class DetailAbsensiPertemuanScreen extends ConsumerStatefulWidget {
  final KelasModel kelas;
  final Map<String, dynamic> pertemuan;

  const DetailAbsensiPertemuanScreen({
    super.key,
    required this.kelas,
    required this.pertemuan,
  });

  @override
  ConsumerState<DetailAbsensiPertemuanScreen> createState() =>
      _DetailAbsensiPertemuanScreenState();
}

class _DetailAbsensiPertemuanScreenState
    extends ConsumerState<DetailAbsensiPertemuanScreen> {
  final DosenService _dosenService = DosenService();
  List<Map<String, dynamic>> _absensiList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAbsensiDetail();
  }

  Future<void> _loadAbsensiDetail() async {
    setState(() => _isLoading = true);
    try {
      final idPertemuan = widget.pertemuan['id_pertemuan'];
      final data = await _dosenService.getAbsensiByPertemuan(idPertemuan);
      
      if (mounted) {
        setState(() {
          _absensiList = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'hadir':
        return Colors.green;
      case 'alpha':
        return Colors.red;
      case 'sakit':
        return Colors.blue;
      case 'izin':
        return Colors.yellow[700]!;
      case 'terlambat':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'hadir':
        return 'HADIR';
      case 'alpha':
        return 'ALPHA';
      case 'sakit':
        return 'SAKIT';
      case 'izin':
        return 'IZIN';
      case 'terlambat':
        return 'TERLAMBAT';
      default:
        return 'BELUM ABSEN';
    }
  }

  @override
  Widget build(BuildContext context) {
    final pertemuanKe = widget.pertemuan['pertemuan_ke'] ?? 0;
    final topik = widget.pertemuan['topik'] ?? 'Pertemuan $pertemuanKe';

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('Pertemuan ke-$pertemuanKe', style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.gradientStart,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GradientBackground(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : Column(
                children: [
                  // Pertemuan Info Card
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          topik,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Kelas: ${widget.kelas.namaKelas}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Pertemuan ke-$pertemuanKe',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Daftar Kehadiran Header
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Daftar Kehadiran Mahasiswa:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // Mahasiswa List
                  Expanded(
                    child: _absensiList.isEmpty
                        ? const Center(
                            child: Text(
                              'Belum ada data absensi',
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _absensiList.length,
                            itemBuilder: (context, index) {
                              final absensi = _absensiList[index];
                              return _buildMahasiswaCard(absensi);
                            },
                          ),
                  ),

                  // Legend
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        _buildLegendItem('Hadir', Colors.green),
                        _buildLegendItem('Alpha', Colors.red),
                        _buildLegendItem('Izin', Colors.yellow[700]!),
                        _buildLegendItem('Sakit', Colors.blue),
                        _buildLegendItem('Terlambat', Colors.pink),
                        _buildLegendItem('Belum Absen', Colors.grey),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildMahasiswaCard(Map<String, dynamic> absensi) {
    final nama = absensi['nama'] ?? '-';
    final nim = absensi['nim'] ?? '-';
    final status = absensi['status'] ?? 'belum_absen';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        title: Text(
          nama,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          nim,
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor(status),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _getStatusLabel(status),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
