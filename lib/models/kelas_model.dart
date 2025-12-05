class KelasModel {
  final int idKelas;
  final String namaKelas;
  final int idMatakuliah;
  final String? namaMatakuliah;
  final String? kodeMk;
  final String? tahunAjaran;
  final String? semester;
  final String? ruangan;
  final String? hari;
  final String? jamMulai;
  final String? jamSelesai;
  
  KelasModel({
    required this.idKelas,
    required this.namaKelas,
    required this.idMatakuliah,
    this.namaMatakuliah,
    this.kodeMk,
    this.tahunAjaran,
    this.semester,
    this.ruangan,
    this.hari,
    this.jamMulai,
    this.jamSelesai,
  });
  
  factory KelasModel.fromJson(Map<String, dynamic> json) {
    return KelasModel(
      idKelas: json['id_kelas'] ?? 0,
      namaKelas: json['nama_kelas'] ?? '',
      idMatakuliah: json['id_matakuliah'] ?? 0,
      namaMatakuliah: json['nama_matakuliah'],
      kodeMk: json['kode_mk'],
      tahunAjaran: json['tahun_ajaran'],
      semester: json['semester'],
      ruangan: json['ruangan'],
      hari: json['hari'],
      jamMulai: json['jam_mulai'],
      jamSelesai: json['jam_selesai'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id_kelas': idKelas,
      'nama_kelas': namaKelas,
      'id_matakuliah': idMatakuliah,
      'tahun_ajaran': tahunAjaran,
      'semester': semester,
      'ruangan': ruangan,
      'hari': hari,
      'jam_mulai': jamMulai,
      'jam_selesai': jamSelesai,
    };
  }
  
  String get jadwal {
    if (hari != null && jamMulai != null && jamSelesai != null) {
      return '$hari, $jamMulai - $jamSelesai';
    }
    return '-';
  }
}
