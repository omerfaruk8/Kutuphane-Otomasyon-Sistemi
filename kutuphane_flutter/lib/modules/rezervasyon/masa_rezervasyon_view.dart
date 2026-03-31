import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MasaRezervasyonView extends StatelessWidget {
  final int? seciliOdaId;
  final String? seciliSeans;
  final DateTime seciliTarih;
  final bool grupModu;
  final int grupKisiSayisi;
  final List<int> seciliSandalyeler;
  final List<int> doluSandalyeler;
  final List<Map<String, dynamic>> odalar;
  final List<Map<String, dynamic>> seanslar;

  final void Function(int?) onOdaChanged;
  final void Function(String?) onSeansChanged;
  final void Function(DateTime) onTarihChanged;
  final void Function(int no) onSandalyeTap;
  final Widget grupInputWidget;
  final VoidCallback onRezerveEt;

  final bool Function(String) isSeansDisabled;

  const MasaRezervasyonView({
    super.key,
    required this.seciliOdaId,
    required this.seciliSeans,
    required this.seciliTarih,
    required this.grupModu,
    required this.grupKisiSayisi,
    required this.seciliSandalyeler,
    required this.doluSandalyeler,
    required this.odalar,
    required this.seanslar,
    required this.onOdaChanged,
    required this.onSeansChanged,
    required this.onTarihChanged,
    required this.onSandalyeTap,
    required this.grupInputWidget,
    required this.onRezerveEt,
    required this.isSeansDisabled,
  });

  final gradientColors = const [Color(0xFF667eea), Color(0xFF764ba2)];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Filtreler",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildFilterPill(
                                context,
                                icon: Icons.calendar_today,
                                label: DateFormat(
                                  'dd.MM.yyyy',
                                ).format(seciliTarih),
                                onTap: () async {
                                  final secilen = await showDatePicker(
                                    context: context,
                                    initialDate: seciliTarih,
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now().add(
                                      const Duration(days: 7),
                                    ),
                                  );
                                  if (secilen != null) onTarihChanged(secilen);
                                },
                              ),
                              const SizedBox(width: 10),
                              _buildDropdownPill<int>(
                                context,
                                hint: "Oda Seç",
                                value: seciliOdaId,
                                items: odalar.map((oda) {
                                  return DropdownMenuItem<int>(
                                    value: oda["odaId"],
                                    child: Text(
                                      "${oda["odaAdi"]} (${oda["tur"]})",
                                    ),
                                  );
                                }).toList(),
                                onChanged: onOdaChanged,
                              ),
                              const SizedBox(width: 10),
                              _buildDropdownPill<String>(
                                context,
                                hint: "Seans Seç",
                                value: seciliSeans,
                                items: seanslar.map((s) {
                                  final bool disabled = isSeansDisabled(
                                    s["value"],
                                  );

                                  return DropdownMenuItem<String>(
                                    value: s["value"],
                                    enabled: !disabled,
                                    child: Text(
                                      s["label"],
                                      style: TextStyle(
                                        color: disabled
                                            ? Colors.grey
                                            : Colors.black87,
                                        decoration: disabled
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: onSeansChanged,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: grupInputWidget,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildLegendItem(Colors.white, "Boş", border: true),
                            const SizedBox(width: 15),
                            _buildLegendItem(const Color(0xFF764ba2), "Seçili"),
                            const SizedBox(width: 15),
                            _buildLegendItem(
                              Colors.redAccent.withOpacity(0.5),
                              "Dolu",
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (seciliOdaId != null && seciliSeans != null)
                          _buildMasaLayout()
                        else
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(40.0),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.touch_app,
                                    size: 50,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "Lütfen Oda ve Seans seçiniz",
                                    style: TextStyle(color: Colors.grey[500]),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: seciliSandalyeler.isEmpty ? null : onRezerveEt,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10b981),
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[300],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
            ),
            child: const Text(
              "Rezerve Et ✅",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 15),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Masa Rezervasyonu",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Yerinizi hemen ayırtın",
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPill(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF764ba2)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownPill<T>(
    BuildContext context, {
    required String hint,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(
            hint,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF764ba2)),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, {bool border = false}) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: border ? Border.all(color: Colors.grey) : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  // Kütüphane yerleşim planını; masa ve etrafındaki sandalyeleri içeren sistematik bir grid yapısında oluşturur.
  Widget _buildMasaLayout() {
    final masalar = List.generate(5, (i) => i + 1);

    return Column(
      children: masalar.map((masaNo) {
        final start = (masaNo - 1) * 6 + 1;
        final ustSira = [start, start + 1, start + 2];
        final altSira = [start + 3, start + 4, start + 5];

        return Container(
          margin: const EdgeInsets.only(bottom: 30),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: ustSira.map((no) => _buildChair(no)).toList(),
              ),
              const SizedBox(height: 5),
              Container(
                width: 160,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFFd4a373),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  "MASA $masaNo",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: altSira.map((no) => _buildChair(no)).toList(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Tekil sandalye birimlerini; doluluk, seçim ve zaman aşımı statülerine göre farklı temalarda render eder.
  Widget _buildChair(int no) {
    bool zamanDoldu = false;
    if (seciliSeans != null) {
      zamanDoldu = isSeansDisabled(seciliSeans!);
    }

    final bool dolu = doluSandalyeler.contains(no);
    final bool secili = seciliSandalyeler.contains(no);

    Color bgColor = Colors.white;
    Color borderColor = Colors.grey.shade400;
    Color textColor = Colors.grey.shade600;

    if (dolu) {
      bgColor = Colors.redAccent.withOpacity(0.2);
      borderColor = Colors.redAccent;
      textColor = Colors.redAccent;
    } else if (zamanDoldu) {
      bgColor = Colors.grey.shade200;
      borderColor = Colors.grey.shade300;
      textColor = Colors.grey.shade400;
    } else if (secili) {
      bgColor = const Color(0xFF764ba2);
      borderColor = const Color(0xFF764ba2);
      textColor = Colors.white;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GestureDetector(
        onTap: (dolu || zamanDoldu) ? null : () => onSandalyeTap(no),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 2),
                boxShadow: (secili && !zamanDoldu)
                    ? [
                        BoxShadow(
                          color: const Color(0xFF764ba2).withOpacity(0.4),
                          blurRadius: 8,
                        ),
                      ]
                    : [],
              ),
              alignment: Alignment.center,
              child: Text(
                "$no",
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
