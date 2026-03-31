import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kutuphane_flutter/modules/login/login_page.dart';
import 'package:kutuphane_flutter/core/api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Kayıtlı IP adresini yükle
  await apiClient.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kütüphane Mobil',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),

      // Uygulama genelinde yerelleştirme (Localization) ve Türkçe dil desteğini yapılandırır:
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('tr', 'TR')],
      locale: const Locale('tr', 'TR'),

      home: const LoginScreen(),
    );
  }
}
