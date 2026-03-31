import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'kitap_list_view.dart';
import 'package:kutuphane_flutter/core/api_client.dart';
import 'package:dio/dio.dart';

// Kullanıcıların kitap envanterini görüntülediği, arama yaptığı ve ödünç alma taleplerini yönettiği denetleyici (Controller) sınıfıdır.
class KitapListPage extends StatefulWidget {
  final Map<String, dynamic> user;
  const KitapListPage({super.key, required this.user});

  @override
  State<KitapListPage> createState() => _KitapListPageState();
}

class _KitapListPageState extends State<KitapListPage> {
  List<dynamic> kitaplar = [];
  List<dynamic> gorunenKitaplar = [];
  bool isLoading = true;
  DateTime? baslangicTarihi;
  DateTime? bitisTarihi;

  @override
  void initState() {
    super.initState();
    _kitaplariGetir();
  }

  // Mevcut tüm kitap verilerini asenkron olarak getirir ve başlangıç listesini oluşturur
  Future<void> _kitaplariGetir() async {
    try {
      final response = await apiClient.get("/kitaplar");

      if (mounted) {
        setState(() {
          kitaplar = response.data;
          gorunenKitaplar = List.from(kitaplar);
          isLoading = false;
        });
      }
    } on DioException catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Oturum süresi doldu, lütfen tekrar giriş yapın."),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Kitap listesi alınamadı.")),
          );
        }
      }
    }
  }

  // Seçilen yayın için belirtilen tarih aralığında ödünç alma talebi oluşturur ve sonucu arayüze bildirir
  Future<void> _oduncAl(Map<String, dynamic> kitap) async {
    final oduncData = {
      "kullanici": {
        "kullaniciId": widget.user["kullaniciId"] ?? widget.user["id"],
      },
      "kitap": {"kitapId": kitap["kitapId"]},
      "baslangicTarihi": DateFormat('yyyy-MM-dd').format(baslangicTarihi!),
      "bitisTarihi": DateFormat('yyyy-MM-dd').format(bitisTarihi!),
    };

    try {
      await apiClient.post("/borrows/add", data: oduncData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "📚 İşlem Başarılı! Kitabı ödünç alma isteğiniz gönderildi.",
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _kitaplariGetir();
      }
    } on DioException catch (e) {
      String mesaj = "İşlem başarısız.";
      if (e.response != null && e.response!.data != null) {
        mesaj = e.response!.data.toString();
      } else {
        mesaj = "${e.message}";
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mesaj),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _oduncAlDialog(Map<String, dynamic> kitap) async {
    baslangicTarihi = DateTime.now();
    bitisTarihi = DateTime.now().add(const Duration(days: 7));

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Column(
              children: [
                const Icon(
                  Icons.calendar_month_rounded,
                  size: 40,
                  color: Color(0xFF764ba2),
                ),
                const SizedBox(height: 10),
                Text(
                  "${kitap['kitapAdi']}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "için tarih seçiniz",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                KitapListView.buildDatePicker(
                  label: "Başlangıç",
                  date: baslangicTarihi,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      locale: const Locale('tr', 'TR'),
                      confirmText: "TAMAM",
                      cancelText: "İPTAL",
                      helpText: "BAŞLANGIÇ TARİHİ SEÇİN",
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 7)),
                    );
                    if (picked != null) {
                      setModalState(() {
                        baslangicTarihi = picked;
                        if (bitisTarihi!.isBefore(picked)) {
                          bitisTarihi = picked.add(const Duration(days: 7));
                        }
                      });
                    }
                  },
                ),
                const SizedBox(height: 15),
                KitapListView.buildDatePicker(
                  label: "Teslim Tarihi",
                  date: bitisTarihi,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      locale: const Locale('tr', 'TR'),
                      confirmText: "TAMAM",
                      cancelText: "İPTAL",
                      helpText: "TESLİM TARİHİ SEÇİN",
                      initialDate: bitisTarihi ?? DateTime.now(),
                      firstDate: baslangicTarihi ?? DateTime.now(),
                      lastDate: baslangicTarihi!.add(const Duration(days: 21)),
                    );
                    if (picked != null) {
                      setModalState(() => bitisTarihi = picked);
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Vazgeç",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF764ba2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: (baslangicTarihi != null && bitisTarihi != null)
                    ? () {
                        Navigator.pop(context);
                        _oduncAl(kitap);
                      }
                    : null,
                child: const Text("Onayla"),
              ),
            ],
          ),
        );
      },
    );
  }

  // Kullanıcı girdisine göre kitap adı, yazar veya kategori bazlı yerel filtreleme uygular.
  void _aramaYap(String query) {
    setState(() {
      if (query.isEmpty) {
        gorunenKitaplar = List.from(kitaplar);
      } else {
        final term = query.toLowerCase();
        gorunenKitaplar = kitaplar.where((k) {
          final adi = k["kitapAdi"]?.toString().toLowerCase() ?? "";
          final yazar = k["yazar"]?.toString().toLowerCase() ?? "";
          final kategori = k["kategori"]?.toString().toLowerCase() ?? "";

          return adi.contains(term) ||
              yazar.contains(term) ||
              kategori.contains(term);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return KitapListView(
      kitaplar: gorunenKitaplar,
      isLoading: isLoading,
      onSearch: _aramaYap,
      onOduncAlPressed: _oduncAlDialog,
    );
  }
}
