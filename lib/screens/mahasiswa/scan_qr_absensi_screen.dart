import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'dart:convert';
import '../../services/mahasiswa_service.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/modern_card.dart';
import '../../config/app_colors.dart';

class ScanQRAbsensiScreen extends ConsumerStatefulWidget {
  const ScanQRAbsensiScreen({super.key});

  @override
  ConsumerState<ScanQRAbsensiScreen> createState() =>
      _ScanQRAbsensiScreenState();
}

class _ScanQRAbsensiScreenState extends ConsumerState<ScanQRAbsensiScreen> {
  MobileScannerController? _scannerController;
  CameraController? _cameraController;
  
  bool _isProcessing = false;
  bool _showCamera = false;
  File? _capturedFace;
  
  Map<String, dynamic>? _scannedData;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController();
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _onQRScanned(BarcodeCapture capture) async {
    if (_isProcessing) return;
    
    final barcode = capture.barcodes.isNotEmpty ? capture.barcodes.first : null;
    if (barcode == null || barcode.rawValue == null) return;

    setState(() => _isProcessing = true);

    try {
      // Parse QR data
      final qrData = jsonDecode(barcode.rawValue!);
      
      // Validate session
      final isValid = await _validateSession(qrData);
      
      if (isValid && mounted) {
        setState(() {
          _scannedData = qrData;
          _showCamera = true;
        });
        await _initializeFaceCamera();
      }
    } catch (e) {
      if (mounted) {
        _showError('QR Code tidak valid atau expired');
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<bool> _validateSession(Map<String, dynamic> qrData) async {
    try {
      // Check location first
      await _checkLocation(qrData);
      
      // Check if session is active
      // TODO: Call API to validate session
      return true;
    } catch (e) {
      if (mounted) {
        _showError(e.toString());
      }
      return false;
    }
  }

  Future<void> _checkLocation(Map<String, dynamic> qrData) async {
    try {
      // Request permission
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || 
          permission == LocationPermission.deniedForever) {
        throw Exception('Izin lokasi ditolak');
      }

      // Get current position
      _currentPosition = await Geolocator.getCurrentPosition();
      
      // Check if within radius
      final sessionLat = qrData['latitude'] as double?;
      final sessionLong = qrData['longitude'] as double?;
      final radiusMeter = qrData['radius_meter'] as int? ?? 50;

      if (sessionLat != null && sessionLong != null) {
        final distance = Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          sessionLat,
          sessionLong,
        );

        if (distance > radiusMeter) {
          throw Exception(
            'Anda terlalu jauh dari lokasi kelas (${distance.toStringAsFixed(0)}m). Maksimal $radiusMeter meter.'
          );
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _initializeFaceCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      _showError('Gagal membuka kamera: ${e.toString()}');
    }
  }

  Future<void> _captureFace() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final image = await _cameraController!.takePicture();
      setState(() {
        _capturedFace = File(image.path);
      });
    } catch (e) {
      _showError('Gagal mengambil foto: ${e.toString()}');
    }
  }

  void _retakeFace() {
    setState(() => _capturedFace = null);
  }

  Future<void> _submitAbsensi() async {
    if (_capturedFace == null || _scannedData == null) return;

    setState(() => _isProcessing = true);

    try {
      final mahasiswaService = MahasiswaService();
      
      // Submit attendance with all data
      final result = await mahasiswaService.submitAbsensi({
        'id_sesi': _scannedData!['id_sesi'],
        'qr_data': jsonEncode(_scannedData),
        'latitude': _currentPosition?.latitude,
        'longitude': _currentPosition?.longitude,
      }, _capturedFace!);

      if (mounted) {
        if (result['success'] == true) {
          _showSuccess('Absensi berhasil dicatat!');
          Navigator.pop(context, true);
        } else {
          _showError(result['message'] ?? 'Gagal submit absensi');
        }
      }
    } catch (e) {
      if (mounted) {
        _showError('Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          _showCamera ? 'Verifikasi Wajah' : 'Scan QR Absensi',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.gradientStart,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GradientBackground(
        child: _showCamera ? _buildFaceCapture() : _buildQRScanner(),
      ),
    );
  }

  Widget _buildQRScanner() {
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: MobileScanner(
            controller: _scannerController,
            onDetect: _onQRScanned,
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.qr_code_scanner,
                  size: 64,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Arahkan kamera ke QR Code',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'QR Code ditampilkan oleh dosen',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFaceCapture() {
    if (_capturedFace != null) {
      return _buildPreview();
    }

    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              Center(
                child: AspectRatio(
                  aspectRatio: _cameraController!.value.aspectRatio,
                  child: CameraPreview(_cameraController!),
                ),
              ),
              // Oval overlay
              Center(
                child: Container(
                  width: 250,
                  height: 350,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 3),
                    borderRadius: BorderRadius.circular(200),
                  ),
                ),
              ),
              // Instructions
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.black54,
                  child: const Text(
                    'Posisikan wajah Anda di dalam oval',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _isProcessing ? null : _captureFace,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Ambil Foto'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreview() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ModernCard(
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _capturedFace!,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Preview Foto Wajah',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isProcessing ? null : _retakeFace,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Ulangi'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.white),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _submitAbsensi,
                    icon: _isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check),
                    label: Text(_isProcessing ? 'Memproses...' : 'Submit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
