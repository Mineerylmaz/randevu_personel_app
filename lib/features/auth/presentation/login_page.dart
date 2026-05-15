import "package:flutter/material.dart";
import "package:dio/dio.dart";

import "../../../core/network/dio_client.dart";
import "../../../core/storage/token_storage.dart";
import "../data/auth_api.dart";
import '../../main/personel_shell_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  final _passFocus = FocusNode();

  bool loading = false;
  bool showPass = false;
  String? error;

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    final email = emailCtrl.text.trim();
    final sifre = passCtrl.text.trim(); // ✅ önemli

    if (email.isEmpty || sifre.isEmpty) {
      setState(() => error = "E-posta ve şifre zorunlu");
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });

    try {
      final dio = DioClient.create();
      final api = AuthApi(dio);

      final token = await api.loginPersonel(email: email, password: sifre);

      await TokenStorage.setToken(token);

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PersonelShellPage()),
      );
    } catch (e) {
      setState(() => error = _friendlyError(e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  String _friendlyError(Object e) {
    // ✅ DioException -> backend message
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data["message"] != null) {
        return data["message"].toString();
      }
      final code = e.response?.statusCode;
      return code != null ? "Hata: $code" : (e.message ?? "Giriş yapılamadı");
    }

    final msg = e.toString().replaceAll("Exception:", "").trim();
    return msg.isEmpty ? "Giriş yapılamadı" : msg;
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              // ✅ klavye açılınca da kaydırılabilir
              padding: EdgeInsets.only(
                left: 22,
                right: 22,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: ConstrainedBox(
                // ✅ içerik kısa olsa bile ortada dursun
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: AutofillGroup(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 20),
                          const Text(
                            "Randevu Personel",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Randevularınızı görüntülemek için giriş yapın.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 32),

                          Container(
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(.05),
                                  blurRadius: 30,
                                  offset: const Offset(0, 18),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (error != null) ...[
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFEF4444,
                                      ).withOpacity(.08),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: const Color(
                                          0xFFEF4444,
                                        ).withOpacity(.25),
                                      ),
                                    ),
                                    child: Text(
                                      error!,
                                      style: const TextStyle(
                                        color: Color(0xFFB91C1C),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],

                                const Text(
                                  "E-posta",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: emailCtrl,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [AutofillHints.email],
                                  onSubmitted:
                                      (_) => FocusScope.of(
                                        context,
                                      ).requestFocus(_passFocus),
                                  decoration: InputDecoration(
                                    hintText: "isim@mail.com",
                                    prefixIcon: const Icon(Icons.mail_rounded),
                                    filled: true,
                                    fillColor: const Color(0xFFF1F5F9),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 18),

                                const Text(
                                  "Şifre",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  focusNode: _passFocus,
                                  controller: passCtrl,
                                  obscureText: !showPass,
                                  textInputAction: TextInputAction.done,
                                  autofillHints: const [AutofillHints.password],
                                  onSubmitted: (_) => loading ? null : _login(),
                                  decoration: InputDecoration(
                                    hintText: "••••••••",
                                    prefixIcon: const Icon(Icons.lock_rounded),
                                    suffixIcon: IconButton(
                                      onPressed:
                                          () => setState(
                                            () => showPass = !showPass,
                                          ),
                                      icon: Icon(
                                        showPass
                                            ? Icons.visibility_off_rounded
                                            : Icons.visibility_rounded,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF1F5F9),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 24),

                                SizedBox(
                                  height: 52,
                                  child: FilledButton(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    onPressed: loading ? null : _login,
                                    child:
                                        loading
                                            ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                            : const Text(
                                              "Giriş Yap",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
