class AppointmentDto {
  final String id;
  final DateTime? baslangic;
  final DateTime? bitis;
  final String? durum;
  final String? notlar;
  final String? musteriAdSoyad;
  final String? hizmetAd;

  AppointmentDto({
    required this.id,
    required this.baslangic,
    required this.bitis,
    required this.durum,
    required this.notlar,
    required this.musteriAdSoyad,
    required this.hizmetAd,
  });

  factory AppointmentDto.fromJson(Map<String, dynamic> j) {
    DateTime? parseDt(dynamic v) {
      if (v == null) return null;
      // MySQL DATETIME string -> DateTime.parse çoğu zaman çalışır
      // "2026-03-02 14:00:00" geliyorsa 'T' ekleyelim:
      final s = v.toString().replaceFirst(" ", "T");
      return DateTime.tryParse(s);
    }

    return AppointmentDto(
      id: (j["id"] ?? "").toString(),
      baslangic: parseDt(j["baslangic"]),
      bitis: parseDt(j["bitis"]),
      durum: j["durum"]?.toString(),
      notlar: j["notlar"]?.toString(),
      musteriAdSoyad: j["musteri_ad_soyad"]?.toString(),
      hizmetAd: j["hizmet_ad"]?.toString(),
    );
  }
}
