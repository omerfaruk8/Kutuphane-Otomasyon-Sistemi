import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'masa_rezervasyon_view.dart';
import 'package:kutuphane_flutter/core/api_client.dart';
import 'package:dio/dio.dart';

class MasaRezervasyonPage extends StatefulWidget {
  final Map<String, dynamic> user;
  const MasaRezervasyonPage({Key? key, required this.user}) : super(key: key);

  @override
  State<MasaRezervasyonPage> createState() => _MasaRezervasyonPageState();
}

class _MasaRezervasyonPageState extends State<MasaRezervasyonPage> {
  int? seciliOdaId;
  String? seciliSeans;
  DateTime seciliTarih = DateTime.now();

  bool grupModu = false;
  int grupKisiSayisi = 1;

  List<int> seciliSandalyeler = [];
  final List<TextEditingController> grupEmailController = [];
  List<int> doluSandalyeler = [];

  final List<Map<String, dynamic>> seanslar = [
    {"label": "09:00 - 11:00", "value": "SEANS9", "endHour": 11},
    {"label": "11:00 - 13:00", "value": "SEANS11", "endHour": 13},
    {"label": "13:00 - 15:00", "value": "SEANS13", "endHour": 15},
    {"label": "15:00 - 17:00", "value": "SEANS15", "endHour": 17},
    {"label": "17:00 - 19:00", "value": "SEANS17", "endHour": 19},
  ];

  final List<Map<String, dynamic>> odalar = [
    {"odaId": 1, "odaAdi": "A01", "tur": "Sesli"},
    {"odaId": 2, "odaAdi": "B01", "tur": "Sessiz"},
    {"odaId": 3, "odaAdi": "A02", "tur": "Sesli"},
  ];

  bool _isSeansDisabled(String seansValue) {
    final now = DateTime.now();
    final bool isToday =
        seciliTarih.year == now.year &&
        seciliTarih.month == now.month &&
        seciliTarih.day == now.day;

    if (!isToday) return false;

    final seans = seanslar.firstWhere(
      (s) => s["value"] == seansValue,
      orElse: () => {},
    );
    if (seans.isEmpty) return true;

    final seansEndTime = DateTime(
      now.year,
      now.month,
      now.day,
      seans["endHour"],
      0,
    );

    final currentTimePlusBuffer = now.add(const Duration(minutes: 15));
    return seansEndTime.isBefore(currentTimePlusBuffer);
  }

  Future<void> _doluSandalyeleriGetir() async {
    if (seciliOdaId == null || seciliSeans == null) {
      setState(() => doluSandalyeler = []);
      return;
    }

    final tarihStr = DateFormat('yyyy-MM-dd').format(seciliTarih);

    try {
      final response = await apiClient.get("/reservations/room/$seciliOdaId");

      if (response.statusCode == 200) {
        final List<dynamic> tumRezervasyonlar = response.data;
        final List<int> dolular = tumRezervasyonlar
            .where((rez) {
              final rSeans = rez["seans"];
              final rTarih = rez["tarih"];
              final rDurum = rez["durum"];
              return rSeans == seciliSeans &&
                  rTarih == tarihStr &&
                  (rDurum == 'AKTIF' || rDurum == 'ONAY_BEKLIYOR');
            })
            .map<int>((rez) => rez["sandalyeNo"] as int)
            .toList();

        setState(() => doluSandalyeler = dolular);
      }
    } catch (e) {
      setState(() => doluSandalyeler = []);
    }
  }

  Future<void> _rezerveEt() async {
    if (seciliOdaId == null ||
        seciliSeans == null ||
        seciliSandalyeler.isEmpty) {
      _hataGoster("Lütfen tüm alanları doldurun.");
      return;
    }

    if (_isSeansDisabled(seciliSeans!)) {
      _hataGoster("Seçtiğiniz seansın süresi dolmuştur.");
      return;
    }

    final tarihStr = DateFormat('yyyy-MM-dd').format(seciliTarih);

    try {
      if (grupModu) {
        if (seciliSandalyeler.length != grupKisiSayisi) {
          _hataGoster("Lütfen $grupKisiSayisi adet sandalye seçin.");
          return;
        }

        for (var controller in grupEmailController) {
          if (controller.text.trim().isEmpty) {
            _hataGoster(
              "Lütfen tüm arkadaşlarınızın e-posta adreslerini girin.",
            );
            return;
          }
        }

        List<Map<String, dynamic>> rezervasyonListesi = [];
        // Grup rezervasyonunda kullanıcı verileri çekme:
        // 1. Ekip Lideri
        rezervasyonListesi.add({
          "kullanici": {
            "kullaniciId": widget.user["kullaniciId"] ?? widget.user["id"],
          },
          "calismaOdasi": {"odaId": seciliOdaId},
          "sandalyeNo": seciliSandalyeler[0],
          "tarih": tarihStr,
          "seans": seciliSeans,
        });

        // 2. Arkadaşlar
        for (int i = 0; i < grupEmailController.length; i++) {
          String email = grupEmailController[i].text.trim();
          try {
            final userResp = await apiClient.get(
              "/kullanicilar/email/${Uri.encodeComponent(email)}",
            );

            if (userResp.data == null) {
              throw Exception("Kullanıcı bulunamadı: $email");
            }
            int arkadasId = userResp.data["kullaniciId"];

            rezervasyonListesi.add({
              "kullanici": {"kullaniciId": arkadasId},
              "calismaOdasi": {"odaId": seciliOdaId},
              "sandalyeNo": seciliSandalyeler[i + 1],
              "tarih": tarihStr,
              "seans": seciliSeans,
            });
          } catch (e) {
            if (e is DioException && e.response?.statusCode == 404) {
              _hataGoster("Kullanıcı bulunamadı: $email");
            } else {
              _hataGoster("Hata: $email işlenirken sorun oluştu.");
            }
            return;
          }
        }

        String? girisYapanEmail = widget.user["email"];

        if (girisYapanEmail == null ||
            girisYapanEmail.toString().trim().isEmpty) {
          try {
            final myId = widget.user["kullaniciId"] ?? widget.user["id"];
            final meResp = await apiClient.get("/kullanicilar/$myId");
            girisYapanEmail = meResp.data["email"];
          } catch (e) {
            _hataGoster("Kullanıcı bilgileri doğrulanamadı.");
            return;
          }
        }

        final grupBody = {
          "girisYapanEmail": girisYapanEmail,
          "rezervasyonlar": rezervasyonListesi,
        };

        final response = await apiClient.post(
          "/reservations/addGrup",
          data: grupBody,
        );

        if (response.statusCode == 200) {
          _basariliIslem("Grup rezervasyonu başarılı! 🎉");
          _temizle();
        }
      } else {
        // Tekli Rezervasyon
        final tekliBody = {
          "kullanici": {
            "kullaniciId": widget.user["kullaniciId"] ?? widget.user["id"],
          },
          "calismaOdasi": {"odaId": seciliOdaId},
          "sandalyeNo": seciliSandalyeler.first,
          "tarih": tarihStr,
          "seans": seciliSeans,
        };

        final response = await apiClient.post(
          "/reservations/add",
          data: tekliBody,
        );

        if (response.statusCode == 200) {
          _basariliIslem("Rezervasyon başarılı! 🎉");
          setState(() => seciliSandalyeler.clear());
          await _doluSandalyeleriGetir();
        }
      }
    } on DioException catch (e) {
      String mesaj = "İşlem başarısız.";
      if (e.response != null && e.response!.data != null) {
        mesaj = e.response!.data.toString();
      }
      _hataGoster(mesaj);
    } catch (e) {
      _hataGoster(e.toString().replaceAll("Exception: ", ""));
    }
  }

  void _basariliIslem(String mesaj) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _hataGoster(String mesaj) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mesaj), backgroundColor: Colors.red));
  }

  void _temizle() {
    setState(() {
      seciliSandalyeler.clear();
      grupEmailController.clear();
      grupModu = false;
      grupKisiSayisi = 1;
    });
    _doluSandalyeleriGetir();
  }

  Widget _grupInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "👥 Grup Rezervasyonu",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Switch(
                value: grupModu,
                activeColor: Colors.amber,
                onChanged: (v) {
                  setState(() {
                    grupModu = v;
                    seciliSandalyeler.clear();
                    grupEmailController.clear();
                    grupKisiSayisi = 1;
                  });
                },
              ),
            ],
          ),
          if (grupModu) ...[
            const Divider(color: Colors.white30),
            Row(
              children: [
                const Text(
                  "Kişi Sayısı: ",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(width: 10),
                DropdownButton<int>(
                  dropdownColor: const Color(0xFF764ba2),
                  value: grupKisiSayisi > 1 ? grupKisiSayisi : null,
                  hint: const Text(
                    "Seçiniz",
                    style: TextStyle(color: Colors.white60),
                  ),
                  style: const TextStyle(color: Colors.white),
                  iconEnabledColor: Colors.amber,
                  underline: Container(),
                  items: List.generate(5, (i) => i + 2)
                      .map(
                        (sayi) => DropdownMenuItem(
                          value: sayi,
                          child: Text("$sayi Kişi"),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val == null) return;
                    setState(() {
                      grupKisiSayisi = val;
                      grupEmailController
                        ..clear()
                        ..addAll(
                          List.generate(
                            val - 1,
                            (_) => TextEditingController(),
                          ),
                        );
                      seciliSandalyeler.clear();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...List.generate(
              grupEmailController.length,
              (i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: TextField(
                  controller: grupEmailController[i],
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "${i + 2}. Üye E-posta",
                    labelStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: Colors.white70,
                      size: 18,
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasaRezervasyonView(
      seciliOdaId: seciliOdaId,
      seciliSeans: seciliSeans,
      seciliTarih: seciliTarih,
      grupModu: grupModu,
      grupKisiSayisi: grupKisiSayisi,
      seciliSandalyeler: seciliSandalyeler,
      doluSandalyeler: doluSandalyeler,
      odalar: odalar,
      seanslar: seanslar,
      grupInputWidget: _grupInput(),
      isSeansDisabled: _isSeansDisabled,
      onOdaChanged: (val) {
        setState(() {
          seciliOdaId = val;
          seciliSandalyeler.clear();
        });
        _doluSandalyeleriGetir();
      },
      onSeansChanged: (val) {
        setState(() {
          seciliSeans = val;
          seciliSandalyeler.clear();
        });
        _doluSandalyeleriGetir();
      },
      onTarihChanged: (val) {
        setState(() {
          seciliTarih = val;
          seciliSandalyeler.clear();
        });
        _doluSandalyeleriGetir();
      },
      onSandalyeTap: (no) {
        if (doluSandalyeler.contains(no)) return;
        setState(() {
          if (grupModu) {
            if (seciliSandalyeler.contains(no)) {
              seciliSandalyeler.remove(no);
            } else {
              if (seciliSandalyeler.length < grupKisiSayisi) {
                seciliSandalyeler.add(no);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "En fazla $grupKisiSayisi sandalye seçebilirsiniz.",
                    ),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            }
          } else {
            if (seciliSandalyeler.contains(no)) {
              seciliSandalyeler.clear();
            } else {
              seciliSandalyeler = [no];
            }
          }
        });
      },
      onRezerveEt: _rezerveEt,
    );
  }
}
