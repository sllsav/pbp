import '../models/makanan_model.dart';

class MakananData {
  static List<MakananModel> getMakanan() => [
    MakananModel(
      id: 1,
      nama: 'Aloevera',
      deskripsi: 'Memiliki banyak nutrisi dan baik untuk pencernaan.',
      gambar: 'assets/images/makanan/aloevera.svg',
      kalori: 8,
      protein: 0.1,
      karbo: 2,
      jenis: 'makanan',
    ),
    MakananModel(
      id: 2,
      nama: 'Jahe',
      deskripsi: 'Membantu meredakan gangguan pencernaan.',
      gambar: 'assets/images/makanan/jahe.jpg',
      kalori: 80,
      protein: 1.8,
      karbo: 17.8,
      jenis: 'makanan',
    ),
    MakananModel(
      id: 3,
      nama: 'Sereal',
      deskripsi: 'Memberi rasa kenyang lebih lama.',
      gambar: 'assets/images/makanan/sereal.svg',
      kalori: 68,
      protein: 2.4,
      karbo: 12,
      jenis: 'makanan',
    ),
    MakananModel(
      id: 4,
      nama: 'Buah Bit',
      deskripsi: 'Mengandung banyak antioksidan.',
      gambar: 'assets/images/makanan/buah_bit.jpg',
      kalori: 43,
      protein: 1.6,
      karbo: 9.6,
      jenis: 'minuman',
    ),
    MakananModel(
      id: 5,
      nama: 'Jeruk Nipis',
      deskripsi: 'Asam tetapi menyegarkan.',
      gambar: 'assets/images/makanan/jeruk_nipis.jpg',
      kalori: 30,
      protein: 0.7,
      karbo: 10.5,
      jenis: 'minuman',
    ),
    MakananModel(
      id: 6,
      nama: 'Pisang',
      deskripsi: 'Dibuat jus lebih enak dan mudah dicerna.',
      gambar: 'assets/images/makanan/pisang.jpg',
      kalori: 89,
      protein: 1.1,
      karbo: 22.8,
      jenis: 'minuman',
    ),
  ];
}

final makananData = MakananData.getMakanan();
