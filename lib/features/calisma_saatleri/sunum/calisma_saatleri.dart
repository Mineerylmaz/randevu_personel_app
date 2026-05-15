import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../veri/calisma_saatleri_api.dart';

class CalismaSaatlerimSayfasi extends StatefulWidget {
  final Dio dio;

  const CalismaSaatlerimSayfasi({super.key, required this.dio});

  @override
  State<CalismaSaatlerimSayfasi> createState() =>
      _CalismaSaatlerimSayfasiState();
}

class _CalismaSaatlerimSayfasiState extends State<CalismaSaatlerimSayfasi> {
  bool loading = true;
  String? error;
  List<Map<String, dynamic>> items = [];

  final gunler = const {
    1: 'Pazartesi',
    2: 'Salı',
    3: 'Çarşamba',
    4: 'Perşembe',
    5: 'Cuma',
    6: 'Cumartesi',
    7: 'Pazar',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final api = CalismaSaatleriApi(widget.dio);

      final list = await api.saatlerim();

      setState(() {
        items = list;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Çalışma saatleri yüklenemedi';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Çalışma Saatlerim',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child:
            loading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                ? ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const SizedBox(height: 80),
                    Center(
                      child: Text(
                        error!,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                )
                : items.isEmpty
                ? ListView(
                  padding: const EdgeInsets.all(16),
                  children: const [
                    SizedBox(height: 80),
                    Center(
                      child: Text(
                        'Henüz çalışma saatin tanımlanmamış.',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                )
                : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final item = items[i];
                    final gun = int.tryParse('${item['gun']}') ?? 1;
                    final baslangic =
                        (item['baslangic_saati'] ?? '').toString();
                    final bitis = (item['bitis_saati'] ?? '').toString();

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.black.withOpacity(.06),
                        ),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                            color: Colors.black.withOpacity(.04),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: primary.withOpacity(.10),
                            child: Icon(
                              Icons.calendar_month_rounded,
                              color: primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  gunler[gun] ?? '-',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$baslangic - $bitis',
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
