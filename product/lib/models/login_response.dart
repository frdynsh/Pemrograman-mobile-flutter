class LoginResponse {
  final bool status;
  final String token;
  final String userEmail;
  final int userId;

  LoginResponse({
    required this.status,
    required this.token,
    required this.userEmail,
    required this.userId,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status:
          json['status'] == true ||
          json['status'] == 1 ||
          json['status'] == 200,

      // Ambil token dengan pengecekan null yang aman
      token: json['data'] != null && json['data']['token'] != null
          ? json['data']['token']
          : (json['message'] ?? "Gagal Login"), // Kadang error ada di 'message'
      // Ambil data user dengan aman (pakai ? dan ??)
      userEmail: json['data'] != null && json['data']['user'] != null
          ? json['data']['user']['email']
          : "",

      // Pastikan ID diubah ke int dengan aman
      userId: json['data'] != null && json['data']['user'] != null
          ? int.parse(json['data']['user']['id'].toString())
          : 0,
    );
  }
}
