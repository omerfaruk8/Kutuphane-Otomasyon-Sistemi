import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Varsayılan API adresi (Yerel ağ IP'si: örn. 192.168.x.x)
String baseUrl = 'http://YOUR_SERVER_IP:8080/api';

class ApiClient {
  late Dio _dio; // 'late' ekledik çünkü constructor içinde initialize edeceğiz

  // Uygulama genelinde tek bir HTTP istemcisi üzerinden bağlantı yönetimi sağlar (Singleton Pattern).
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // HTTP isteklerine otomatik olarak JWT (Bearer Token) ekleyen ve hata yönetimini merkezi hale getiren ara katman (Interceptor).
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('userAuthToken');

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          return handler.next(e);
        },
      ),
    );
  }

  // Mevcut Dio instance'ına erişim sağlar.
  Dio get dio => _dio;

  // Yerel depolamadaki (Shared Preferences) sunucu yapılandırmalarını yükler.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIp = prefs.getString('server_ip');

    if (savedIp != null && savedIp.isNotEmpty) {
      baseUrl = 'http://$savedIp:8080/api';
      _dio.options.baseUrl = baseUrl; // Dio'nun ayarını güncelle
    }
  }

  // Dinamik sunucu adresi girişi ile API bağlantı ayarlarını çalışma zamanında (runtime) günceller ve kalıcı hale getirir.
  Future<void> updateBaseUrl(String newIp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_ip', newIp);

    baseUrl = 'http://$newIp:8080/api';
    _dio.options.baseUrl = baseUrl; // Dio'yu anlık günceller
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }

  Future<Response> get(String path) async {
    return await _dio.get(path);
  }

  Future<Response> delete(String path) async {
    return await _dio.delete(path);
  }

  Future<Response> put(String path, dynamic data) async {
    return await _dio.put(path, data: data);
  }
}

final apiClient = ApiClient();
