class AlarmModel {
  int? _id;
  int _userId;
  String _jam;
  String _judul;
  String _deskripsi;
  bool _aktif;

  AlarmModel({
    int? id,
    required int userId,
    required String jam,
    required String judul,
    required String deskripsi,
    bool aktif = true,
  }) : _id = id,
       _userId = userId,
       _jam = jam,
       _judul = judul,
       _deskripsi = deskripsi,
       _aktif = aktif;

  int? get id => _id;
  int get userId => _userId;
  String get jam => _jam;
  String get judul => _judul;
  String get deskripsi => _deskripsi;
  bool get aktif => _aktif;

  set id(int? value) => _id = value;
  set userId(int value) => _userId = value;
  set jam(String value) => _jam = value;
  set judul(String value) => _judul = value;
  set deskripsi(String value) => _deskripsi = value;
  set aktif(bool value) => _aktif = value;

  Map<String, dynamic> toMap() => {
    'id': _id,
    'userId': _userId,
    'jam': _jam,
    'judul': _judul,
    'deskripsi': _deskripsi,
    'aktif': _aktif ? 1 : 0,
  };

  factory AlarmModel.fromMap(Map<String, dynamic> map) => AlarmModel(
    id: map['id'] as int?,
    userId: map['userId'] as int,
    jam: map['jam'] as String,
    judul: map['judul'] as String,
    deskripsi: map['deskripsi'] as String,
    aktif: (map['aktif'] as int) == 1,
  );
}
