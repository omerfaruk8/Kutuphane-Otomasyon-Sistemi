import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:kutuphane_flutter/core/api_client.dart';
import 'package:kutuphane_flutter/modules/login/login_page.dart';
import 'register_view.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController adSoyadController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => isLoading = true);

    final Map<String, dynamic> body = {
      "adSoyad": adSoyadController.text.trim(),
      "email": emailController.text.trim(),
      "password": passwordController.text.trim(),
    };

    try {
      await apiClient.post('/register', data: body);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Kayıt başarılı! Lütfen giriş yapınız."),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      }
    } on DioException catch (e) {
      String errorMessage = "Kayıt sırasında hata oluştu.";

      if (e.response != null) {
        final data = e.response?.data;

        if (data is Map) {
          if (data.containsKey('message') && data.keys.length > 5) {
            errorMessage = data['message'].toString();
          } else {
            errorMessage = data.values.join("\n");
          }
        } else if (data is String) {
          errorMessage = data;
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Bir hata oluştu: $e"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RegisterView(
      adSoyadController: adSoyadController,
      emailController: emailController,
      passwordController: passwordController,
      isLoading: isLoading,
      onRegisterPressed: _register,
      formKey: _formKey,
      onLoginPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      },
    );
  }
}
