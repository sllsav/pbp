import '../models/informasi_model.dart';

class InformasiData {
  static List<InformasiModel> getInformasi() => [
    InformasiModel(
      id: 1,
      judul: 'Pentingnya minum air',
      isi: 'Cukupi kebutuhan cairan secara bertahap sepanjang hari.',
    ),
    InformasiModel(
      id: 2,
      judul: 'Tidur yang berkualitas',
      isi: 'Jadwal tidur teratur membantu tubuh memulihkan energi.',
    ),
    InformasiModel(
      id: 3,
      judul: 'Faktor Resiko',
      isi:
          'Pola makan tidak teratur, stres, dan kebiasaan buruk dapat meningkatkan risiko.',
    ),
    InformasiModel(
      id: 4,
      judul: 'Gejala yang Perlu Diwaspadai',
      isi: 'Jika gejala berlangsung lama, segera periksakan ke dokter.',
    ),
  ];
}

final informasiData = InformasiData.getInformasi();
