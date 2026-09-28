class InformasiModel {
  int _id;
  String _judul;
  String _isi;
  String? _gambar;

  InformasiModel({
    required int id,
    required String judul,
    required String isi,
    String? gambar,
  }) : _id = id,
       _judul = judul,
       _isi = isi,
       _gambar = gambar;

  int get id => _id;
  String get judul => _judul;
  String get isi => _isi;
  String? get gambar => _gambar;

  set judul(String value) => _judul = value;
  set isi(String value) => _isi = value;
  set gambar(String? value) => _gambar = value;
}
