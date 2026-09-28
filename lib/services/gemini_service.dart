import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  static const _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash-lite:generateContent';

  static const _systemPrompt = '''
Kamu adalah asisten edukasi kesehatan pada aplikasi mobile.
Tugasmu HANYA menjawab pertanyaan seputar herbal, makanan/minuman sehat, dan nutrisi umum.
Berikan jawaban yang padat tetapi lengkap, jelas, dan tidak terlalu singkat. Gunakan bahasa Indonesia yang mudah dipahami.
Untuk pertanyaan kesehatan, susun jawaban dengan format yang relevan:
1. Ringkasan jawaban langsung.
2. Penjelasan manfaat, penyebab, atau cara kerja secara singkat namun cukup.
3. Saran praktis yang aman dilakukan.
4. Hal yang perlu dihindari atau batasannya.
5. Tanda bahaya atau kapan perlu berkonsultasi dengan dokter jika relevan.
Gunakan bullet point jika membuat jawaban lebih mudah dibaca. Jangan mengulang pertanyaan pengguna.
Selalu sertakan kalimat penutup: "Ini bukan pengganti nasihat medis profesional. Konsultasikan ke dokter untuk kondisi kesehatan spesifik."
Jangan memberi diagnosis, dosis obat, atau menyarankan pengobatan pengganti terapi medis.
''';

  Future<String> askGemini(String userMessage) async {
    final apiKey = dotenv.env['GEMINI_API_KEY']?.trim();
    if (apiKey == null || apiKey.isEmpty || apiKey.startsWith('REPLACE_')) {
      throw const GeminiException(
        'API key Gemini belum dikonfigurasi. Ganti placeholder di file .env dengan key baru.',
      );
    }

    final requestBody = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': '$_systemPrompt\n\nPertanyaan pengguna: $userMessage'},
          ],
        },
      ],
      'generationConfig': {'temperature': 0.4, 'maxOutputTokens': 768},
    });

    late http.Response response;
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        response = await http
            .post(
              Uri.parse('$_baseUrl?key=$apiKey'),
              headers: {'Content-Type': 'application/json'},
              body: requestBody,
            )
            .timeout(const Duration(seconds: 15));
      } on http.ClientException {
        if (attempt == 1) {
          throw const GeminiException(
            'HP tidak dapat terhubung ke Gemini. Periksa koneksi internet dan permission aplikasi.',
          );
        }
        await _waitBeforeRetry(attempt);
        continue;
      } on TimeoutException {
        if (attempt == 1) {
          throw const GeminiException(
            'Request Gemini timeout. Periksa internet lalu coba lagi.',
          );
        }
        await _waitBeforeRetry(attempt);
        continue;
      } on Exception {
        if (attempt == 1) {
          throw const GeminiException(
            'Koneksi ke Gemini gagal. Periksa jaringan HP lalu coba lagi.',
          );
        }
        await _waitBeforeRetry(attempt);
        continue;
      }

      if (![429, 500, 503].contains(response.statusCode) || attempt == 1) {
        break;
      }

      await _waitBeforeRetry(attempt);
    }

    if (response.statusCode != 200) {
      final detail = _errorDetail(response.body);
      throw GeminiException(
        'Gagal memanggil Gemini (${response.statusCode}). $detail',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = data['candidates'] as List<dynamic>?;
    final text = candidates?.isNotEmpty == true
        ? ((candidates!.first as Map<String, dynamic>)['content']
                  as Map<String, dynamic>)['parts']
              as List<dynamic>
        : null;

    if (text == null || text.isEmpty) {
      throw const GeminiException('Gemini tidak mengembalikan jawaban.');
    }

    return ((text.first as Map<String, dynamic>)['text'] as String?)?.trim() ??
        'Gemini tidak mengembalikan jawaban.';
  }

  String _errorDetail(String body) {
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      final error = data['error'] as Map<String, dynamic>?;
      return error?['message'] as String? ??
          'Periksa API key dan model Gemini.';
    } catch (_) {
      return 'Periksa API key dan konfigurasi model Gemini.';
    }
  }

  Future<void> _waitBeforeRetry(int attempt) async {
    await Future<void>.delayed(Duration(milliseconds: 350 + (attempt * 250)));
  }
}

class GeminiException implements Exception {
  const GeminiException(this.message);
  final String message;

  @override
  String toString() => message;
}
