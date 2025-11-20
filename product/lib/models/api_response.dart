class ApiResponse {
  final bool status;
  final String data;
  final int? code;

  ApiResponse({required this.status, required this.data, this.code});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      // PERBAIKAN UTAMA DI SINI:
      // Kita cek: Apakah statusnya true? ATAU 1? ATAU 200? ATAU 201?
      status:
          json['status'] == true ||
          json['status'] == 1 ||
          json['status'] == 200 ||
          json['status'] == 201,

      // Pakai .toString() agar data apapun diubah jadi teks, anti-null
      data: json['data']?.toString() ?? "",
      code: json['code'],
    );
  }
}
