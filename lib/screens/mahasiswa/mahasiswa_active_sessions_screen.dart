import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../services/mahasiswa_service.dart';
import '../../models/sesi_model.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/modern_card.dart';
import '../../config/app_colors.dart';

class MahasiswaActiveSessionsScreen extends ConsumerStatefulWidget {
  const MahasiswaActiveSessionsScreen({super.key});

  @override
  ConsumerState<MahasiswaActiveSessionsScreen> createState() =>
      _MahasiswaActiveSessionsScreenState();
}

class _MahasiswaActiveSessionsScreenState
    extends ConsumerState<MahasiswaActiveSessionsScreen> {
  List<SesiModel> _sessions = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadActiveSessions();
  }

  Future<void> _loadActiveSessions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final mahasiswaService = MahasiswaService();
      final sessions = await mahasiswaService.getActiveSessions();

      if (mounted) {
        setState(() {
          _sessions = sessions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Kelas Aktif',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.gradientStart,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadActiveSessions,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: GradientBackground(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.white),
              const SizedBox(height: 16),
              Text(
                'Error: $_error',
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadActiveSessions,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_sessions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.event_busy,
                size: 80,
                color: Colors.white70,
              ),
              const SizedBox(height: 24),
              const Text(
                'Tidak Ada Kelas Aktif',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Belum ada sesi absensi yang dibuka oleh dosen.\nSilakan cek kembali nanti.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadActiveSessions,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _sessions.length,
      itemBuilder: (context, index) {
        final sesi = _sessions[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildSessionCard(sesi),
        );
      },
    );
  }

  Widget _buildSessionCard(SesiModel sesi) {
    final dateFormat = DateFormat('HH:mm');
    final now = DateTime.now();
    final elapsed = now.difference(sesi.waktuBuka).inMinutes;
    final remaining = sesi.durasiMenit - elapsed;
    final isExpired = remaining <= 0;

    return ModernCard(
      onTap: isExpired
          ? null
          : () {
              // Navigate to QR Scanner with session info
              Navigator.pushNamed(
                context,
                '/mahasiswa/scan-qr',
                arguments: sesi,
              );
            },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sesi.namaMatakuliah ?? 'Mata Kuliah',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kelas: ${sesi.namaKelas ?? '-'}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isExpired ? Colors.red : Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isExpired ? 'EXPIRED' : 'AKTIF',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.topic, 'Topik', sesi.topik ?? '-'),
          _buildInfoRow(
            Icons.numbers,
            'Pertemuan',
            'Ke-${sesi.pertemuanKe ?? '-'}',
          ),
          _buildInfoRow(
            Icons.access_time,
            'Dibuka',
            dateFormat.format(sesi.waktuBuka),
          ),
          _buildInfoRow(
            Icons.timer,
            'Sisa Waktu',
            isExpired ? 'Waktu Habis' : '$remaining menit',
            color: isExpired ? Colors.red : Colors.green,
          ),
          const SizedBox(height: 12),
          if (!isExpired)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/mahasiswa/scan-qr',
                    arguments: sesi,
                  );
                },
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan QR Absensi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: const Text(
                'Sesi sudah berakhir',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
