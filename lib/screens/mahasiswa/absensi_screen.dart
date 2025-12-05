import 'package:flutter/material.dart';

// Simple placeholder - this screen is deprecated, use scan_qr_absensi_screen.dart
class AbsensiScreen extends StatelessWidget {
  const AbsensiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Absensi'),
      ),
      body: const Center(
        child: Text('Use QR Scanner from dashboard'),
      ),
    );
  }
}
