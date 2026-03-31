import 'package:dio/dio.dart';
import 'package:kutuphane_flutter/core/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Kullanıcı kimlik doğrulama süreçlerini ve JWT (JSON Web Token) yönetimini sağlayan servis katmanıdır.
class AuthService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    try {
      final response = await _apiClient.post(
        '/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        // Farklı backend cevap formatlarıyla (userId, id, kullaniciId) uyumluluk sağlamak adına kimlik bilgisini normalize eder
        final dynamic rawId =
            data['userId'] ?? data['id'] ?? data['kullaniciId'];
        final String? token = data['token'];
        final String? userName = data['userName'];

        // Gelen veriyi tip güvenliği (Type Safety) için tamsayıya (Integer) dönüştürür
        final int? userId = rawId is int
            ? rawId
            : (rawId is String ? int.tryParse(rawId) : null);

        if (token != null && userId != null) {
          final prefs = await SharedPreferences.getInstance();

          await prefs.setString('userAuthToken', token);
          await prefs.setInt('kullaniciId', userId);
          await prefs.setString('userName', userName ?? 'Kullanıcı');

          // ID'yi Dashboard'un beklediği anahtarla map'e ekle
          data['kullaniciId'] = userId;

          return data;
        }

        return null;
      } else {
        return null;
      }
    } on DioException catch (_) {
      return null;
    }
  }
}
