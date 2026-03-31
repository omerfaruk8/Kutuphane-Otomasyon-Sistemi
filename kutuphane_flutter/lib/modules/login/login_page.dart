import 'package:flutter/material.dart';
import 'package:kutuphane_flutter/modules/dashboard/dashboard_page.dart';
import 'package:kutuphane_flutter/modules/login/login_view.dart';
import 'package:kutuphane_flutter/modules/register/register_page.dart';
import 'package:kutuphane_flutter/services/auth_service.dart';
import 'package:kutuphane_flutter/modules/admin/admin_panel_page.dart';
import 'package:kutuphane_flutter/core/api_client.dart';

// Kullanıcı kimlik doğrulama süreçlerini ve sunucu bağlantı yapılandırmalarını yöneten ana giriş ekranıdır.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _error;

  // Yerel ağ üzerinden backend erişimi için dinamik IP adresi yapılandırma arayüzünü sunar.
  void _showIpSettingsDialog(BuildContext context) {
    String currentIp = "";
    try {
      currentIp = baseUrl.split('//')[1].split(':')[0];
    } catch (e) {
      currentIp = "";
    }

    final TextEditingController ipController = TextEditingController(
      text: currentIp,
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Sunucu Bağlantı Ayarı"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Bilgisayarınızın IPv4 adresini giriniz.\n(Örn: 192.168.1.35)",
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: ipController,
              decoration: const InputDecoration(
                labelText: "IP Adresi",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.wifi),
                hintText: "192.168.x.x",
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (ipController.text.isNotEmpty) {
                await apiClient.updateBaseUrl(ipController.text.trim());

                if (mounted) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Sunucu adresi güncellendi: ${ipController.text}",
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            child: const Text("Kaydet"),
          ),
        ],
      ),
    );
  }

  // Kullanıcı bilgilerini doğrular ve dönen rol bilgisine (ADMIN/USER) göre ilgili modüle yönlendirme yapar.
  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final user = await _authService.loginUser(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (mounted) {
      setState(() => _isLoading = false);
    }

    if (user != null) {
      final String role = user['role'] ?? 'USER';

      if (role == 'ADMIN') {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminPanelPage()),
          );
        }
      } else {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardScreen(user: user),
            ),
          );
        }
      }
    } else {
      if (mounted) {
        setState(() => _error = 'Geçersiz e-posta veya şifre.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoginView(
      emailController: _emailController,
      passwordController: _passwordController,
      isLoading: _isLoading,
      error: _error,
      onLoginPressed: _login,
      onSettingsPressed: () => _showIpSettingsDialog(context),
      onRegisterPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RegisterPage()),
        );
      },
    );
  }
}
