class MataKuliahModel {
  final int idMatakuliah;
  final String kodeMk;
  final String namaMatakuliah;
  final int sks;
  final int? semester;
  final String? nipDosen;
  final String? namaDosen;
  
  MataKuliahModel({
    required this.idMatakuliah,
    required this.kodeMk,
    required this.namaMatakuliah,
    required this.sks,
    this.semester,
    this.nipDosen,
    this.namaDosen,
  });
  
  factory MataKuliahModel.fromJson(Map<String, dynamic> json) {
    return MataKuliahModel(
      idMatakuliah: json['id_matakuliah'] ?? 0,
      kodeMk: json['kode_mk'] ?? '',
      namaMatakuliah: json['nama_matakuliah'] ?? '',
      sks: json['sks'] ?? 0,
      semester: json['semester'],
      nipDosen: json['nip_dosen'],
      namaDosen: json['nama_dosen'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id_matakuliah': idMatakuliah,
      'kode_mk': kodeMk,
      'nama_matakuliah': namaMatakuliah,
      'sks': sks,
      'semester': semester,
      'nip_dosen': nipDosen,
    };
  }
}
