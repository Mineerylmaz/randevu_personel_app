import 'package:dio/dio.dart';

class ReviewsApi {
  final Dio dio;

  ReviewsApi(this.dio);

  Future<List<ReviewDto>> list() async {
    final res = await dio.get('/personel/randevular/yorumlar');

    final data = res.data['data'] as List<dynamic>? ?? [];

    return data
        .map((e) => ReviewDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

class ReviewDto {
  final String id;
  final int rating;
  final String comment;
  final String customerName;
  final String staffName;
  final String? staffTitle;
  final DateTime? createdAt;

  ReviewDto({
    required this.id,
    required this.rating,
    required this.comment,
    required this.customerName,
    required this.staffName,
    required this.staffTitle,
    required this.createdAt,
  });

  factory ReviewDto.fromJson(Map<String, dynamic> json) {
    return ReviewDto(
      id: json['id'].toString(),
      rating: int.tryParse(json['rating'].toString()) ?? 0,
      comment: json['comment']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? 'Müşteri',
      staffName: json['staffName']?.toString() ?? '',
      staffTitle: json['staffTitle']?.toString(),
      createdAt:
          json['createdAt'] == null
              ? null
              : DateTime.tryParse(json['createdAt'].toString()),
    );
  }
}
