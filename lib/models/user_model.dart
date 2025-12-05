class UserModel {
  final int idUser;
  final String username;
  final String nama;
  final String level;
  final String? nim;
  final String? nip;
  
  UserModel({
    required this.idUser,
    required this.username,
    required this.nama,
    required this.level,
    this.nim,
    this.nip,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      idUser: json['id_user'] ?? 0,
      username: json['username'] ?? '',
      nama: json['nama'] ?? '',
      level: json['level'] ?? '',
      nim: json['nim'],
      nip: json['nip'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id_user': idUser,
      'username': username,
      'nama': nama,
      'level': level,
      'nim': nim,
      'nip': nip,
    };
  }
  
  bool get isAdmin => level == 'admin';
  bool get isDosen => level == 'dosen';
  bool get isMahasiswa => level == 'mahasiswa';
}
