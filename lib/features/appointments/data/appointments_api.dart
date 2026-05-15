import "package:dio/dio.dart";
import "models.dart";

class AppointmentsApi {
  final Dio dio;
  AppointmentsApi(this.dio);

  Future<List<AppointmentDto>> list({
    required String status,
    required int page,
    required int limit,
  }) async {
    final r = await dio.get(
      "/personel/randevular",
      queryParameters: {"status": status, "page": page, "limit": limit},
    );

    final data = r.data as Map<String, dynamic>;
    final items = (data["items"] as List? ?? []);
    return items
        .map((e) => AppointmentDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> approve(String id) async {
    await dio.post("/personel/randevular/$id/onayla");
  }

  Future<void> cancel(String id) async {
    await dio.post("/personel/randevular/$id/iptal");
  }
}
