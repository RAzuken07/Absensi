import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/kelas_model.dart';
import '../models/sesi_model.dart';
import '../services/dosen_service.dart';

final dosenServiceProvider = Provider((ref) => DosenService());

// Kelas Dosen Provider
final dosenKelasListProvider = StateNotifierProvider<DosenKelasNotifier, AsyncValue<List<KelasModel>>>((ref) {
  return DosenKelasNotifier(ref.read(dosenServiceProvider));
});

class DosenKelasNotifier extends StateNotifier<AsyncValue<List<KelasModel>>> {
  final DosenService _dosenService;
  
  DosenKelasNotifier(this._dosenService) : super(const AsyncValue.loading()) {
    loadKelas();
  }
  
  Future<void> loadKelas() async {
    state = const AsyncValue.loading();
    try {
      final kelas = await _dosenService.getKelas();
      state = AsyncValue.data(kelas);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// Active Sessions Provider
final dosenActiveSessionsProvider = StateNotifierProvider<DosenActiveSessionsNotifier, AsyncValue<List<SesiModel>>>((ref) {
  return DosenActiveSessionsNotifier(ref.read(dosenServiceProvider));
});

class DosenActiveSessionsNotifier extends StateNotifier<AsyncValue<List<SesiModel>>> {
  final DosenService _dosenService;
  
  DosenActiveSessionsNotifier(this._dosenService) : super(const AsyncValue.loading()) {
    loadActiveSessions();
  }
  
  Future<void> loadActiveSessions() async {
    state = const AsyncValue.loading();
    try {
      final sessions = await _dosenService.getActiveSessions();
      state = AsyncValue.data(sessions);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  Future<Map<String, dynamic>> openSesi(Map<String, dynamic> data) async {
    final result = await _dosenService.openSesi(data);
    if (result['success']) {
      await loadActiveSessions();
    }
    return result;
  }
  
  Future<bool> closeSesi(int idSesi) async {
    final result = await _dosenService.closeSesi(idSesi);
    if (result['success']) {
      await loadActiveSessions();
    }
    return result['success'];
  }
}

// Rekap Provider
final rekapProvider = FutureProvider.family<List<dynamic>, int>((ref, idKelas) async {
  final dosenService = ref.read(dosenServiceProvider);
  return await dosenService.getRekap(idKelas);
});
