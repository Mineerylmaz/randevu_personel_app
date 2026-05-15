import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/network/dio_client.dart';
import '../data/profile_api.dart';
import '../../../core/config/app_config.dart';

class ProfilePage extends StatefulWidget {
  final Color primary;

  const ProfilePage({super.key, required this.primary});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool loading = true;
  bool saving = false;
  String? error;

  final adCtrl = TextEditingController();
  final unvanCtrl = TextEditingController();

  String email = '';
  String? fotoUrl;
  XFile? selectedImage;
  Uint8List? selectedImageBytes;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    adCtrl.dispose();
    unvanCtrl.dispose();
    super.dispose();
  }

  String? _resolvePhotoUrl(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;

    final value = raw.trim();

    if (value.startsWith('http')) return value;

    return '${AppConfig.baseUrl}$value';
  }

  String? _toDbPhotoPath(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;

    final value = raw.trim();

    if (value.contains('/uploads/')) {
      return value.substring(value.indexOf('/uploads/'));
    }

    return value;
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final api = ProfileApi(DioClient.create());
      final profile = await api.getProfile();

      if (!mounted) return;
      setState(() {
        adCtrl.text = profile.adSoyad;
        unvanCtrl.text = profile.unvan;
        email = profile.email;
        fotoUrl = _resolvePhotoUrl(profile.fotoUrl);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.toString().replaceAll('Exception:', '').trim();
      });
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );

    if (image == null) return;

    final bytes = await image.readAsBytes();

    setState(() {
      selectedImage = image;
      selectedImageBytes = bytes;
    });
  }

  Future<void> _save() async {
    setState(() => saving = true);

    try {
      final api = ProfileApi(DioClient.create());

      String? uploadedFotoUrl;

      // Yeni foto seçildiyse upload et
      if (selectedImage != null) {
        uploadedFotoUrl = await api.uploadPhoto(selectedImage!);
      }

      // SADECE isim + ünvan güncelle
      await api.update(
        adSoyad: adCtrl.text.trim(),
        unvan: unvanCtrl.text.trim(),
      );

      if (!mounted) return;

      // Upload olduysa ekranda yeni fotoyu göster
      if (uploadedFotoUrl != null) {
        fotoUrl = _resolvePhotoUrl(uploadedFotoUrl);
      }

      setState(() {
        selectedImage = null;
        selectedImageBytes = null;
      });

      _snack('Profil güncellendi ✅');
    } catch (e) {
      if (!mounted) return;
      _snack(e.toString().replaceAll('Exception:', '').trim());
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  void _openPasswordSheet() {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final againCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
        bool localSaving = false;

        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> changePassword() async {
              if (newCtrl.text.trim() != againCtrl.text.trim()) {
                _snack('Yeni şifreler aynı değil');
                return;
              }

              if (newCtrl.text.trim().length < 6) {
                _snack('Şifre en az 6 karakter olmalı');
                return;
              }

              setModalState(() => localSaving = true);

              try {
                final api = ProfileApi(DioClient.create());

                await api.changePassword(
                  oldPassword: oldCtrl.text.trim(),
                  newPassword: newCtrl.text.trim(),
                );

                if (!mounted) return;
                Navigator.pop(context);
                _snack('Şifre değiştirildi ✅');
              } catch (e) {
                _snack(e.toString().replaceAll('Exception:', '').trim());
              } finally {
                setModalState(() => localSaving = false);
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                bottom: MediaQuery.of(context).viewInsets.bottom + 18,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Şifre değiştir',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Hesabın için yeni bir şifre belirle.',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _passwordField(oldCtrl, 'Mevcut şifre'),
                  const SizedBox(height: 12),
                  _passwordField(newCtrl, 'Yeni şifre'),
                  const SizedBox(height: 12),
                  _passwordField(againCtrl, 'Yeni şifre tekrar'),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: localSaving ? null : changePassword,
                      icon:
                          localSaving
                              ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Icon(Icons.lock_reset_rounded),
                      label: Text(
                        localSaving ? 'Değiştiriliyor...' : 'Şifreyi değiştir',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: widget.primary,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _passwordField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  void _snack(String text) {
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
    const bg = Color(0xFFF6F8FC);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child:
            loading
                ? Center(
                  child: CircularProgressIndicator(color: widget.primary),
                )
                : error != null
                ? Center(
                  child: Text(
                    error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
                : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                  children: [
                    _header(),
                    const SizedBox(height: 18),
                    _profileCard(),
                    const SizedBox(height: 18),
                    _formCard(),
                    const SizedBox(height: 18),
                    _securityCard(),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: saving ? null : _save,
                      icon:
                          saving
                              ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Icon(Icons.save_rounded),
                      label: Text(
                        saving ? 'Kaydediliyor...' : 'Profili kaydet',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: widget.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Profilim',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.blueGrey.shade900,
            ),
          ),
        ),
        IconButton.filledTonal(
          onPressed: _load,
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
    );
  }

  Widget _profileCard() {
    ImageProvider? image;

    if (selectedImageBytes != null) {
      image = MemoryImage(selectedImageBytes!);
    } else if (fotoUrl != null && fotoUrl!.isNotEmpty) {
      image = NetworkImage(fotoUrl!);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [widget.primary, widget.primary.withOpacity(.78)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: widget.primary.withOpacity(.25),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 55,
                backgroundColor: Colors.white.withOpacity(.25),
                backgroundImage: image,
                child:
                    image == null
                        ? const Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 58,
                        )
                        : null,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: InkWell(
                  onTap: _pickImage,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.18),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      color: widget.primary,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            adCtrl.text.trim().isEmpty ? 'Personel' : adCtrl.text.trim(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            email,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(.88),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _formCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kişisel bilgiler',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          _input(adCtrl, 'Ad soyad', Icons.person_outline_rounded),
          const SizedBox(height: 12),
          _input(unvanCtrl, 'Unvan', Icons.badge_outlined),
        ],
      ),
    );
  }

  Widget _securityCard() {
    return _card(
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: widget.primary.withOpacity(.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.lock_outline_rounded, color: widget.primary),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Güvenlik',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
                SizedBox(height: 3),
                Text(
                  'Personel hesabının şifresini değiştir.',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _openPasswordSheet,
            child: const Text(
              'Değiştir',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _input(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.black.withOpacity(.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.045),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}
