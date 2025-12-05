class DosenModel {
  final String nip;
  final String nama;
  final String? email;
  final String? noHp;
  final bool faceRegistered;
  
  DosenModel({
    required this.nip,
    required this.nama,
    this.email,
    this.noHp,
    this.faceRegistered = false,
  });
  
  factory DosenModel.fromJson(Map<String, dynamic> json) {
    return DosenModel(
      nip: json['nip'] ?? '',
      nama: json['nama'] ?? '',
      email: json['email'],
      noHp: json['no_hp'],
      faceRegistered: (json['face_registered'] ?? 0) == 1,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'nip': nip,
      'nama': nama,
      'email': email,
      'no_hp': noHp,
    };
  }
}
