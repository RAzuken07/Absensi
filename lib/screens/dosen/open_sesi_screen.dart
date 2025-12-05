import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/kelas_model.dart';
import '../../providers/dosen_provider.dart';
import '../../config/app_colors.dart';
import '../../widgets/gradient_background.dart';

class OpenSesiScreen extends ConsumerStatefulWidget {
  const OpenSesiScreen({super.key});

  @override
  ConsumerState<OpenSesiScreen> createState() => _OpenSesiScreenState();
}

class _OpenSesiScreenState extends ConsumerState<OpenSesiScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _sessionData;

  @override
  void initState() {
    super.initState();
    // Auto-open session when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openSession();
    });
  }

  Future<void> _openSession() async {
    final kelas = ModalRoute.of(context)!.settings.arguments as KelasModel;
    
    setState(() => _isLoading = true);

    // Simple data - only id_kelas required, backend auto-generates rest
    final data = {
      'id_kelas': kelas.idKelas,
    };

    final result = await ref.read(dosenActiveSessionsProvider.notifier).openSesi(data);

    if (mounted) {
      setState(() => _isLoading = false);

      if (result['success']) {
        setState(() {
          _sessionData = result['data'];
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sesi berhasil dibuka!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Gagal membuka sesi'),
            backgroundColor: Colors.red,
          ),
        );
        // Go back if failed with result false
        Navigator.pop(context, false);
      }
    }
  }

  // Add method to close and return
  Future<void> _closeAndReturn() async {
    Navigator.pop(context, true); // Return true to refresh status
  }

  @override
  Widget build(BuildContext context) {
    final kelas = ModalRoute.of(context)!.settings.arguments as KelasModel;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Sesi Absensi', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.gradientStart,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, true), // Return true on back
        ),
      ),
      body: GradientBackground(
        child: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Membuka sesi absensi...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              )
            : _sessionData != null
                ? _buildQRCodeDisplay(kelas)
                : const Center(
                    child: Text(
                      'Gagal membuka sesi',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
      ),
    );
  }

  Widget _buildQRCodeDisplay(KelasModel kelas) {
    final qrData = _sessionData!['qr_data'] ?? '';
    final pertemuanKe = _sessionData!['pertemuan_ke'] ?? 1;
    final durasiMenit = _sessionData!['durasi_menit'] ?? 90;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Kelas Info Card
          Container(
            width: double.infinity,
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
                  kelas.namaKelas,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pertemuan ke-$pertemuanKe',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Durasi: $durasiMenit menit',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // QR Code Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Scan QR Code untuk Absensi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: QrImageView(
                    data: qrData,
                    version: 1,  // Force version 1 untuk QR paling sederhana
                    errorCorrectionLevel: QrErrorCorrectLevel.L,  // Low error correction
                    size: 300,
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Mahasiswa dapat scan QR code ini untuk melakukan absensi',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Close Session Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _closeSession(),
              icon: const Icon(Icons.stop),
              label: const Text('Tutup Sesi Absensi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _closeSession() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tutup Sesi?'),
        content: const Text('Apakah Anda yakin ingin menutup sesi absensi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Tutup Sesi'),
          ),
        ],
      ),
    );

    if (confirm == true && _sessionData != null) {
      final success = await ref
          .read(dosenActiveSessionsProvider.notifier)
          .closeSesi(_sessionData!['id_sesi']);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sesi berhasil ditutup'),
              backgroundColor: Colors.green,
            ),
          );
          // Return true to trigger refresh in kelas detail
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal menutup sesi'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
