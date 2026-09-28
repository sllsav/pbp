class UserModel {
  int? _id;
  String _nama;
  String _email;
  String _password;
  String? _fotoProfil;

  UserModel({
    int? id,
    required String nama,
    required String email,
    required String password,
    String? fotoProfil,
  }) : _id = id,
       _nama = nama,
       _email = email,
       _password = password,
       _fotoProfil = fotoProfil;

  int? get id => _id;
  String get nama => _nama;
  String get email => _email;
  String get password => _password;
  String? get fotoProfil => _fotoProfil;

  set id(int? value) => _id = value;
  set nama(String value) => _nama = value;
  set email(String value) => _email = value;
  set password(String value) => _password = value;
  set fotoProfil(String? value) => _fotoProfil = value;

  Map<String, dynamic> toMap() => {
    'id': _id,
    'nama': _nama,
    'email': _email,
    'password': _password,
    'fotoProfil': _fotoProfil,
  };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    id: map['id'] as int?,
    nama: map['nama'] as String,
    email: map['email'] as String,
    password: map['password'] as String,
    fotoProfil: map['fotoProfil'] as String?,
  );
}
