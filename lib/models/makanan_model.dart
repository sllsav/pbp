class MakananModel {
  int _id;
  String _nama;
  String _deskripsi;
  String _gambar;
  double _kalori;
  double _protein;
  double _karbo;
  String _jenis;

  MakananModel({
    required int id,
    required String nama,
    required String deskripsi,
    required String gambar,
    required double kalori,
    required double protein,
    required double karbo,
    required String jenis,
  }) : _id = id,
       _nama = nama,
       _deskripsi = deskripsi,
       _gambar = gambar,
       _kalori = kalori,
       _protein = protein,
       _karbo = karbo,
       _jenis = jenis;

  int get id => _id;
  String get nama => _nama;
  String get deskripsi => _deskripsi;
  String get gambar => _gambar;
  double get kalori => _kalori;
  double get protein => _protein;
  double get karbo => _karbo;
  String get jenis => _jenis;

  set nama(String value) => _nama = value;
  set deskripsi(String value) => _deskripsi = value;
  set gambar(String value) => _gambar = value;
  set kalori(double value) => _kalori = value;
  set protein(double value) => _protein = value;
  set karbo(double value) => _karbo = value;
  set jenis(String value) => _jenis = value;
}
