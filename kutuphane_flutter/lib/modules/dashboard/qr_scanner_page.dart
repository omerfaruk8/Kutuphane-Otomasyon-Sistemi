import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

// Kütüphane masalarındaki QR kodları tarayarak kullanıcı check-in işlemini başlatan kamera arayüzüdür.
class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  bool isScanCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QR ile Giriş Yap"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            ),
          ),
        ),
      ),
      body: MobileScanner(
        onDetect: (capture) {
          if (isScanCompleted) return;

          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            final String? code = barcode.rawValue;

            // Okunan QR verisinin sistem tarafından tanımlanan doğrulama anahtarı ile eşleşmesini kontrol eder.
            if (code == "KUTUPHANE_GIRIS_2025") {
              setState(() => isScanCompleted = true);
              Navigator.pop(context, true);
              break;
            }
          }
        },
      ),
    );
  }
}
