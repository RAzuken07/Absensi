import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/kelas_model.dart';
import '../../services/dosen_service.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/modern_card.dart';
import '../../config/app_colors.dart';
import 'rekap_kehadiran_screen.dart';

class KelasDetailScreen extends ConsumerStatefulWidget {
  final KelasModel kelas;

  const KelasDetailScreen({super.key, required this.kelas});

  @override
  ConsumerState<KelasDetailScreen> createState() =>
      _KelasDetailScreenState();
}

class _KelasDetailScreenState extends ConsumerState<KelasDetailScreen> {
  List<int> _createdPertemuan = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPertemuanStatus();
  }

  Future<void> _loadPertemuanStatus() async {
    setState(() => _isLoading = true);
    
    try {
      final dosenService = DosenService();
      final status = await dosenService.getPertemuanStatus(widget.kelas.idKelas);
      
      if (mounted) {
        setState(() {
          _createdPertemuan = status;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading pertemuan status: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Get status for each pertemuan - green if created, white if not
  String _getPertemuanStatus(int pertemuanKe) {
    if (_createdPertemuan.contains(pertemuanKe)) {
      return 'hadir'; // Green - session created
    }
    return 'belum_absen'; // White - not created yet
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Detail Kelas',
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
                // Kelas Info Card
                ModernCard(
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
                      const SizedBox(height: 8),
                      Text(
                        'Kelas: ${widget.kelas.namaKelas}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Waktu: ${widget.kelas.hari ?? '-'} / ${widget.kelas.jamMulai ?? '-'} - ${widget.kelas.jamSelesai ?? '-'}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Buka Sesi Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            // TODO: Add face verification back later
                            // For now, go directly to open sesi
                            final result = await Navigator.pushNamed(
                              context,
                              '/dosen/open-sesi',
                              arguments: widget.kelas,
                            );
                            // Refresh grid if session opened successfully
                            if (result == true) {
                              _loadPertemuanStatus();
                            }
                          },
                          icon: const Icon(Icons.qr_code_2),
                          label: const Text('Buka Sesi Absensi'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Rekap Kehadiran Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RekapKehadiranScreen(kelas: widget.kelas),
                              ),
                            );
                          },
                          icon: const Icon(Icons.assessment),
                          label: const Text('Rekap Kehadiran'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: AppColors.primary, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Status Kehadiran Card
                ModernCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Status 16 Pertemuan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (!_isLoading)
                            IconButton(
                              icon: const Icon(Icons.refresh, size: 20),
                              onPressed: _loadPertemuanStatus,
                              tooltip: 'Refresh',
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      if (_isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else
                        // Grid 16 Pertemuan (4x4)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 1,
                          ),
                          itemCount: 16,
                          itemBuilder: (context, index) {
                            final pertemuanKe = index + 1;
                            final status = _getPertemuanStatus(pertemuanKe);
                            
                            return _buildPertemuanBox(pertemuanKe, status);
                          },
                        ),
                      
                      const SizedBox(height: 16),
                      
                      // Legend - simplified
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          _buildLegend(AppColors.statusHadir, 'Sudah Dibuat'),
                          _buildLegend(AppColors.statusBelumAbsen, 'Belum Dibuat'),
                        ],
                      ),
                      
                      if (_createdPertemuan.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Pertemuan yang sudah dibuat: ${_createdPertemuan.join(", ")}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPertemuanBox(int pertemuan, String status) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getStatusColor(status),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: status == 'belum_absen' 
              ? AppColors.border 
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          '$pertemuan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: status == 'belum_absen'
                ? AppColors.textPrimary
                : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: color == AppColors.statusBelumAbsen 
                  ? AppColors.border 
                  : Colors.transparent,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
