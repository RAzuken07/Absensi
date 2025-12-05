import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dosen_model.dart';
import '../models/mahasiswa_model.dart';
import '../models/matakuliah_model.dart';
import '../models/kelas_model.dart';
import '../services/admin_service.dart';

final adminServiceProvider = Provider((ref) => AdminService());

// Dosen Provider
final dosenListProvider = StateNotifierProvider<DosenListNotifier, AsyncValue<List<DosenModel>>>((ref) {
  return DosenListNotifier(ref.read(adminServiceProvider));
});

class DosenListNotifier extends StateNotifier<AsyncValue<List<DosenModel>>> {
  final AdminService _adminService;
  
  DosenListNotifier(this._adminService) : super(const AsyncValue.loading()) {
    loadDosen();
  }
  
  Future<void> loadDosen() async {
    state = const AsyncValue.loading();
    try {
      final dosen = await _adminService.getAllDosen();
      state = AsyncValue.data(dosen);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  Future<bool> createDosen(Map<String, dynamic> data) async {
    final result = await _adminService.createDosen(data);
    if (result['success']) {
      await loadDosen();
    }
    return result['success'];
  }
  
  Future<bool> updateDosen(String nip, Map<String, dynamic> data) async {
    final result = await _adminService.updateDosen(nip, data);
    if (result['success']) {
      await loadDosen();
    }
    return result['success'];
  }
  
  Future<bool> deleteDosen(String nip) async {
    final result = await _adminService.deleteDosen(nip);
    if (result['success']) {
      await loadDosen();
    }
    return result['success'];
  }
}

// Mahasiswa Provider
final mahasiswaListProvider = StateNotifierProvider<MahasiswaListNotifier, AsyncValue<List<MahasiswaModel>>>((ref) {
  return MahasiswaListNotifier(ref.read(adminServiceProvider));
});

class MahasiswaListNotifier extends StateNotifier<AsyncValue<List<MahasiswaModel>>> {
  final AdminService _adminService;
  
  MahasiswaListNotifier(this._adminService) : super(const AsyncValue.loading()) {
    loadMahasiswa();
  }
  
  Future<void> loadMahasiswa() async {
    state = const AsyncValue.loading();
    try {
      final mahasiswa = await _adminService.getAllMahasiswa();
      state = AsyncValue.data(mahasiswa);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  Future<bool> createMahasiswa(Map<String, dynamic> data) async {
    final result = await _adminService.createMahasiswa(data);
    if (result['success']) {
      await loadMahasiswa();
    }
    return result['success'];
  }
  
  Future<bool> updateMahasiswa(String nim, Map<String, dynamic> data) async {
    final result = await _adminService.updateMahasiswa(nim, data);
    if (result['success']) {
      await loadMahasiswa();
    }
    return result['success'];
  }
  
  Future<bool> deleteMahasiswa(String nim) async {
    final result = await _adminService.deleteMahasiswa(nim);
    if (result['success']) {
      await loadMahasiswa();
    }
    return result['success'];
  }
}

// Mata Kuliah Provider
final matakuliahListProvider = StateNotifierProvider<MataKuliahListNotifier, AsyncValue<List<MataKuliahModel>>>((ref) {
  return MataKuliahListNotifier(ref.read(adminServiceProvider));
});

class MataKuliahListNotifier extends StateNotifier<AsyncValue<List<MataKuliahModel>>> {
  final AdminService _adminService;
  
  MataKuliahListNotifier(this._adminService) : super(const AsyncValue.loading()) {
    loadMataKuliah();
  }
  
  Future<void> loadMataKuliah() async {
    state = const AsyncValue.loading();
    try {
      final matakuliah = await _adminService.getAllMataKuliah();
      state = AsyncValue.data(matakuliah);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  Future<bool> createMataKuliah(Map<String, dynamic> data) async {
    final result = await _adminService.createMataKuliah(data);
    if (result['success']) {
      await loadMataKuliah();
    }
    return result['success'];
  }
  
  Future<bool> updateMataKuliah(int id, Map<String, dynamic> data) async {
    final result = await _adminService.updateMataKuliah(id, data);
    if (result['success']) {
      await loadMataKuliah();
    }
    return result['success'];
  }
  
  Future<bool> deleteMataKuliah(int id) async {
    final result = await _adminService.deleteMataKuliah(id);
    if (result['success']) {
      await loadMataKuliah();
    }
    return result['success'];
  }
}

// Kelas Provider
final kelasListProvider = StateNotifierProvider<KelasListNotifier, AsyncValue<List<KelasModel>>>((ref) {
  return KelasListNotifier(ref.read(adminServiceProvider));
});

class KelasListNotifier extends StateNotifier<AsyncValue<List<KelasModel>>> {
  final AdminService _adminService;
  
  KelasListNotifier(this._adminService) : super(const AsyncValue.loading()) {
    loadKelas();
  }
  
  Future<void> loadKelas() async {
    state = const AsyncValue.loading();
    try {
      final kelas = await _adminService.getAllKelas();
      state = AsyncValue.data(kelas);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  Future<bool> createKelas(Map<String, dynamic> data) async {
    final result = await _adminService.createKelas(data);
    if (result['success']) {
      await loadKelas();
    }
    return result['success'];
  }
  
  Future<bool> updateKelas(int id, Map<String, dynamic> data) async {
    final result = await _adminService.updateKelas(id, data);
    if (result['success']) {
      await loadKelas();
    }
    return result['success'];
  }
  
  Future<bool> deleteKelas(int id) async {
    final result = await _adminService.deleteKelas(id);
    if (result['success']) {
      await loadKelas();
    }
    return result['success'];
  }
}
