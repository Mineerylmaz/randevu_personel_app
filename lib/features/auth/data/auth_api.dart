import "package:dio/dio.dart";

class AuthApi {
  final Dio dio;
  AuthApi(this.dio);

  Future<String> loginPersonel({
    required String email,
    required String password, // UI'da şifre
  }) async {
    final r = await dio.post(
      "/auth/personel/login",
      data: {
        "email": email.trim().toLowerCase(),
        "sifre": password, // ✅ backend "sifre" bekliyor
      },
    );

    final data = r.data as Map<String, dynamic>;
    final token = (data["token"] ?? "").toString();
    if (token.isEmpty) throw Exception(data["message"] ?? "Token gelmedi");
    return token;
  }
}
