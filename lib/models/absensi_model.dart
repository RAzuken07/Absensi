class AbsensiModel {
  final int idAbsensi;
  final String nim;
  final int idPertemuan;
  final int? idSesi;
  final String status;
  final DateTime waktuAbsen;
  final String? metode;
  final double? confidenceScore;
  final double? lokasiLat;
  final double? lokasiLong;
  final String? namaKelas;
  final String? namaMatakuliah;
  final int? pertemuanKe;
  final String? topik;
  
  AbsensiModel({
    required this.idAbsensi,
    required this.nim,
    required this.idPertemuan,
    this.idSesi,
    required this.status,
    required this.waktuAbsen,
    this.metode,
    this.confidenceScore,
    this.lokasiLat,
    this.lokasiLong,
    this.namaKelas,
    this.namaMatakuliah,
    this.pertemuanKe,
    this.topik,
  });
  
  factory AbsensiModel.fromJson(Map<String, dynamic> json) {
    return AbsensiModel(
      idAbsensi: json['id_absensi'] ?? 0,
      nim: json['nim'] ?? '',
      idPertemuan: json['id_pertemuan'] ?? 0,
      idSesi: json['id_sesi'],
      status: json['status'] ?? 'hadir',
      waktuAbsen: json['waktu_absen'] != null
          ? DateTime.parse(json['waktu_absen'])
          : DateTime.now(),
      metode: json['metode'],
      confidenceScore: json['confidence_score'] != null
          ? double.parse(json['confidence_score'].toString())
          : null,
      lokasiLat: json['lokasi_lat'] != null
          ? double.parse(json['lokasi_lat'].toString())
          : null,
      lokasiLong: json['lokasi_long'] != null
          ? double.parse(json['lokasi_long'].toString())
          : null,
      namaKelas: json['nama_kelas'],
      namaMatakuliah: json['nama_matakuliah'],
      pertemuanKe: json['pertemuan_ke'],
      topik: json['topik'],
    );
  }
  
  bool get isHadir => status == 'hadir';
  bool get isIzin => status == 'izin';
  bool get isSakit => status == 'sakit';
  bool get isAlpha => status == 'alpha';
}
