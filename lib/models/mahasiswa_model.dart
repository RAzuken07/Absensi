class MahasiswaModel {
  final String nim;
  final String nama;
  final String? email;
  final String? noHp;
  final int? idKelas;
  final String? namaKelas;
  final String? angkatan;
  final bool faceRegistered;
  
  MahasiswaModel({
    required this.nim,
    required this.nama,
    this.email,
    this.noHp,
    this.idKelas,
    this.namaKelas,
    this.angkatan,
    this.faceRegistered = false,
  });
  
  factory MahasiswaModel.fromJson(Map<String, dynamic> json) {
    return MahasiswaModel(
      nim: json['nim'] ?? '',
      nama: json['nama'] ?? '',
      email: json['email'],
      noHp: json['no_hp'],
      idKelas: json['id_kelas'],
      namaKelas: json['nama_kelas'],
      angkatan: json['angkatan'],
      faceRegistered: (json['face_registered'] ?? 0) == 1,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'nim': nim,
      'nama': nama,
      'email': email,
      'no_hp': noHp,
      'id_kelas': idKelas,
      'angkatan': angkatan,
    };
  }
}
