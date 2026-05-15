import "package:flutter/material.dart";

import "core/storage/token_storage.dart";

import "features/auth/presentation/login_page.dart";
import "features/main/personel_shell_page.dart";

void main() {
  runApp(const PersonelApp());
}

class PersonelApp extends StatelessWidget {
  const PersonelApp({super.key});

  Future<Widget> _start() async {
    final token = await TokenStorage.getToken();

    if (token != null && token.isNotEmpty) {
      return const PersonelShellPage();
    }

    return const LoginPage();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Randevu Personel",
      theme: ThemeData(useMaterial3: true),
      home: FutureBuilder<Widget>(
        future: _start(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return snap.data!;
        },
      ),
    );
  }
}
