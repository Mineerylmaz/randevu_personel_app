import 'dart:io';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class ProfileApi {
  final Dio dio;

  ProfileApi(this.dio);

  /// PROFİL GETİR
  Future<ProfileDto> getProfile() async {
    final res = await dio.get('/personel/randevular/profil');

    return ProfileDto.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<void> update({required String adSoyad, required String unvan}) async {
    await dio.put(
      '/personel/randevular/profil',
      data: {'ad_soyad': adSoyad, 'unvan': unvan},
    );
  }

  /// FOTOĞRAF YÜKLE
  Future<String> uploadPhoto(XFile file) async {
    final bytes = await file.readAsBytes();

    final formData = FormData.fromMap({
      'foto': MultipartFile.fromBytes(bytes, filename: file.name),
    });

    final res = await dio.post(
      '/personel/randevular/profil/foto',
      data: formData,
    );

    return res.data['foto_url'].toString();
  }

  /// ŞİFRE DEĞİŞTİR
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await dio.put(
      '/personel/randevular/profil/sifre',
      data: {'oldPassword': oldPassword, 'newPassword': newPassword},
    );
  }
}

class ProfileDto {
  final String id;
  final String adSoyad;
  final String unvan;
  final String email;
  final String? fotoUrl;

  ProfileDto({
    required this.id,
    required this.adSoyad,
    required this.unvan,
    required this.email,
    required this.fotoUrl,
  });

  factory ProfileDto.fromJson(Map<String, dynamic> json) {
    return ProfileDto(
      id: json['id'].toString(),
      adSoyad: json['ad_soyad']?.toString() ?? '',
      unvan: json['unvan']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fotoUrl: json['foto_url']?.toString(),
    );
  }
}
