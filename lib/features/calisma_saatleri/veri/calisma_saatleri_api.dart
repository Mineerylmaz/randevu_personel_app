import 'package:dio/dio.dart';

class CalismaSaatleriApi {
  final Dio dio;

  CalismaSaatleriApi(this.dio);

  Future<List<Map<String, dynamic>>> saatlerim() async {
    final res = await dio.get('/personel/randevular/calisma-saatlerim');

    final raw = res.data;

    final list = raw is Map && raw['data'] is List ? raw['data'] as List : [];

    return list.map((e) => (e as Map).cast<String, dynamic>()).toList();
  }
}
