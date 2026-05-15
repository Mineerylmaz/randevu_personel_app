// appointments_page.dart
// Mevcut API/DB bağlantılarına dokunulmadı. Sadece tasarım düzenlendi.

import "dart:ui";
import "package:flutter/material.dart";
import "package:intl/intl.dart";

import "../../../core/network/dio_client.dart";
import "../../../core/storage/token_storage.dart";
import "../../../core/storage/branding_storage.dart";
import "../../auth/presentation/login_page.dart";
import "../data/appointments_api.dart";
import "../data/models.dart";

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  bool loading = true;
  bool acting = false;
  String? error;

  List<AppointmentDto> items = [];
  String status = "bekliyor";

  Color primary = const Color(0xFF2563EB);
  String title = "Randevularım";
  String? logoUrl;

  final df = DateFormat("dd.MM.yyyy HH:mm");

  @override
  void initState() {
    super.initState();
    _loadBrandingThenData();
  }

  Future<void> _loadBrandingThenData() async {
    await _loadBranding();
    await _load();
  }

  Future<void> _loadBranding() async {
    final b = await BrandingStorage.getBranding();
    if (b == null) return;

    final hex = (b["ana_renk"] ?? "#2563EB").toString();
    final t = (b["giris_baslik"] ?? "").toString();
    final l = (b["logo_url"] ?? "").toString();

    if (!mounted) return;
    setState(() {
      primary = _hexToColor(hex);
      if (t.isNotEmpty) title = t;
      logoUrl = _resolveLogoUrl(l);
    });
  }

  String? _resolveLogoUrl(String raw) {
    if (raw.isEmpty) return null;
    if (raw.startsWith("http")) return raw;
    const apiBase = "http://10.0.2.2:4000";
    return "$apiBase$raw";
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final dio = DioClient.create();
      final api = AppointmentsApi(dio);
      final list = await api.list(status: status, page: 1, limit: 20);

      if (!mounted) return;
      setState(() => items = list);
    } catch (e) {
      if (!mounted) return;
      setState(() => error = e.toString().replaceAll("Exception:", "").trim());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _approve(AppointmentDto a) async {
    final ok = await _confirmAction(
      context,
      title: "Randevu onaylansın mı?",
      desc: "Bu işlem randevunun durumunu onaylı yapar.",
      confirmText: "Onayla",
      confirmColor: primary,
    );

    if (ok != true) return;

    setState(() => acting = true);
    try {
      final dio = DioClient.create();
      final api = AppointmentsApi(dio);
      await api.approve(a.id);

      if (status == "bekliyor" || status == "bekleyen") {
        if (!mounted) return;
        setState(() => items.removeWhere((x) => x.id == a.id));
      } else {
        await _load();
      }

      if (!mounted) return;
      _showSnack("Randevu onaylandı ✅");
    } catch (e) {
      if (!mounted) return;
      _showSnack(e.toString().replaceAll("Exception:", "").trim());
    } finally {
      if (mounted) setState(() => acting = false);
    }
  }

  Future<void> _cancel(AppointmentDto a) async {
    final ok = await _confirmAction(
      context,
      title: "Randevu reddedilsin mi?",
      desc: "Bu işlem randevunun durumunu iptal yapar.",
      confirmText: "Reddet",
      confirmColor: Colors.red,
    );

    if (ok != true) return;

    setState(() => acting = true);
    try {
      final dio = DioClient.create();
      final api = AppointmentsApi(dio);
      await api.cancel(a.id);

      if (status == "bekliyor" || status == "bekleyen") {
        if (!mounted) return;
        setState(() => items.removeWhere((x) => x.id == a.id));
      } else {
        await _load();
      }

      if (!mounted) return;
      _showSnack("Randevu reddedildi ❌");
    } catch (e) {
      if (!mounted) return;
      _showSnack(e.toString().replaceAll("Exception:", "").trim());
    } finally {
      if (mounted) setState(() => acting = false);
    }
  }

  Future<void> _logout() async {
    await TokenStorage.clear();
    await BrandingStorage.clear();

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  void _showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = const Color(0xFFF6F8FC);

    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: primary),
        scaffoldBackgroundColor: bg,
      ),
      child: Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _load,
            color: primary,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _header()),
                SliverToBoxAdapter(child: _statusFilter()),
                if (acting)
                  const SliverToBoxAdapter(
                    child: LinearProgressIndicator(minHeight: 2),
                  ),
                SliverFillRemaining(hasScrollBody: true, child: _content()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, primary.withOpacity(.78)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(.25),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          _logoBox(),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Randevu taleplerini buradan yönet",
                  style: TextStyle(
                    color: Colors.white.withOpacity(.86),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _roundIcon(Icons.refresh_rounded, _load),
          const SizedBox(width: 8),
          _roundIcon(Icons.logout_rounded, _logout),
        ],
      ),
    );
  }

  Widget _logoBox() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(.25)),
      ),
      clipBehavior: Clip.antiAlias,
      child:
          logoUrl == null
              ? const Icon(Icons.calendar_month_rounded, color: Colors.white)
              : Image.network(
                logoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return const Icon(
                    Icons.calendar_month_rounded,
                    color: Colors.white,
                  );
                },
              ),
    );
  }

  Widget _roundIcon(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: acting ? null : onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.18),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withOpacity(.25)),
        ),
        child: Icon(icon, color: Colors.white, size: 21),
      ),
    );
  }

  Widget _statusFilter() {
    final filters = [
      ("bekliyor", "Bekleyen"),
      ("onayli", "Onaylı"),
      ("iptal", "İptal"),
      ("all", "Tümü"),
    ];

    return SizedBox(
      height: 54,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, i) {
          final f = filters[i];
          final selected = status == f.$1;

          return ChoiceChip(
            selected: selected,
            label: Text(f.$2),
            showCheckmark: false,
            selectedColor: primary,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              color: selected ? Colors.white : const Color(0xFF334155),
              fontWeight: FontWeight.w900,
            ),
            side: BorderSide(
              color: selected ? primary : Colors.black.withOpacity(.06),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
            onSelected: (_) {
              if (status == f.$1) return;
              setState(() => status = f.$1);
              _load();
            },
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: filters.length,
      ),
    );
  }

  Widget _content() {
    if (loading) {
      return Center(child: CircularProgressIndicator(color: primary));
    }

    if (error != null) {
      return _emptyState(
        icon: Icons.error_outline_rounded,
        title: "Bir sorun oluştu",
        desc: error!,
        buttonText: "Tekrar dene",
        onTap: _load,
      );
    }

    if (items.isEmpty) {
      return _emptyState(
        icon: Icons.event_busy_rounded,
        title: "Randevu yok",
        desc: "Bu durumda listelenecek randevu bulunamadı.",
        buttonText: "Yenile",
        onTap: _load,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 22),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _appointmentCard(items[i]),
    );
  }

  Widget _appointmentCard(AppointmentDto a) {
    final musteri = (a.musteriAdSoyad ?? "Müşteri").toString();
    final hizmet = (a.hizmetAd ?? "Hizmet").toString();
    final durum = (a.durum ?? "bekliyor").toString();
    final not = (a.notlar ?? "").toString().trim();

    final baslangic = a.baslangic;
    final time = baslangic == null ? "-" : df.format(baslangic);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.055),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: primary.withOpacity(.11),
                    child: Icon(Icons.person_rounded, color: primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      musteri,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  _statusChip(durum),
                ],
              ),
              const SizedBox(height: 14),
              _infoRow(Icons.access_time_rounded, time),
              const SizedBox(height: 8),
              _infoRow(Icons.spa_rounded, hizmet),
              if (not.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black.withOpacity(.04)),
                  ),
                  child: Text(
                    not,
                    style: const TextStyle(
                      color: Color(0xFF475569),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              if (durum == "bekliyor" || durum == "bekleyen") ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: acting ? null : () => _cancel(a),
                        icon: const Icon(Icons.close_rounded),
                        label: const Text("Reddet"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: BorderSide(color: Colors.red.withOpacity(.28)),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: acting ? null : () => _approve(a),
                        icon: const Icon(Icons.check_rounded),
                        label: const Text("Onayla"),
                        style: FilledButton.styleFrom(
                          backgroundColor: primary,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF64748B)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusChip(String durum) {
    late final Color bg;
    late final Color fg;
    late final String text;

    switch (durum) {
      case "onayli":
        bg = Colors.green.withOpacity(.11);
        fg = Colors.green.shade800;
        text = "Onaylı";
        break;
      case "iptal":
        bg = Colors.red.withOpacity(.11);
        fg = Colors.red.shade800;
        text = "İptal";
        break;
      default:
        bg = primary.withOpacity(.11);
        fg = primary;
        text = "Bekleyen";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withOpacity(.22)),
      ),
      child: Text(
        text,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w900),
      ),
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String desc,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.black.withOpacity(.05)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: primary),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                desc,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onTap,
                style: FilledButton.styleFrom(
                  backgroundColor: primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(buttonText),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmAction(
    BuildContext context, {
    required String title,
    required String desc,
    required String confirmText,
    required Color confirmColor,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                desc,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Vazgeç"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: confirmColor,
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(confirmText),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Color _hexToColor(String hex) {
    try {
      var h = hex.trim().replaceAll("#", "");
      if (h.length == 6) h = "FF$h";
      return Color(int.parse(h, radix: 16));
    } catch (_) {
      return const Color(0xFF2563EB);
    }
  }
}
