import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/produk.dart';
import '../models/api_response.dart';
import '../models/login_response.dart';

class ApiService {
  // Sesuaikan IP Laptop Anda (Cek ipconfig lagi jika ganti WiFi)
  static const String _baseUrl = "http://192.168.1.4:8080";

  // Helper: Menyiapkan Header dengan Token Bearer
  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      return {'Content-Type': 'application/json'};
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // 1. REGISTRASI
  Future<ApiResponse> registrasi(
    String nama,
    String email,
    String password,
  ) async {
    final url = Uri.parse('$_baseUrl/registrasi');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'nama': nama, 'email': email, 'password': password}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return ApiResponse.fromJson(json.decode(response.body));
      } else {
        return ApiResponse(
          status: false,
          data: 'Gagal: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse(status: false, data: 'Error Koneksi: $e');
    }
  }

  // 2. LOGIN
  Future<LoginResponse> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        return LoginResponse.fromJson(json.decode(response.body));
      } else {
        // Menangani jika respons error bukan JSON valid
        try {
          var errorData = json.decode(response.body);
          return LoginResponse(
            status: false,
            token:
                errorData['data']?.toString() ??
                'Login gagal',
            userEmail: '',
            userId: 0,
          );
        } catch (_) {
          return LoginResponse(
            status: false,
            token: 'Gagal: ${response.statusCode}',
            userEmail: '',
            userId: 0,
          );
        }
      }
    } catch (e) {
      return LoginResponse(
        status: false,
        token: 'Error Koneksi: $e',
        userEmail: '',
        userId: 0,
      );
    }
  }

  // 3. GET PRODUK
  Future<List<Produk>> getProduk() async {
    final url = Uri.parse('$_baseUrl/produk');
    // Tambahkan try-catch agar loading berhenti jika error
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body)['data'];
        return jsonData.map((json) => Produk.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('TOKEN_EXPIRED');
      } else {
        throw Exception('Gagal memuat produk: ${response.statusCode}');
      }
    } catch (e) {
      rethrow; // Lempar error ke UI agar bisa ditangani
    }
  }

  // 4. CREATE PRODUK
  Future<ApiResponse> createProduk(Produk produk) async {
    final url = Uri.parse('$_baseUrl/produk');
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(produk.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return ApiResponse.fromJson(json.decode(response.body));
      } else {
        return ApiResponse(
          status: false,
          data: 'Gagal: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse(status: false, data: 'Error: $e');
    }
  }

  // 5. UPDATE PRODUK (Perbaikan: Tambah Try-Catch & Logika JSON)
  Future<ApiResponse> updateProduk(String id, Produk produk) async {
    final url = Uri.parse('$_baseUrl/produk/$id');
    try {
      final headers = await _getAuthHeaders();
      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(produk.toJson()),
      );

      if (response.statusCode == 200) {
        return ApiResponse.fromJson(json.decode(response.body));
      }
      return ApiResponse(
        status: false,
        data: 'Gagal Update: ${response.statusCode}',
      );
    } catch (e) {
      return ApiResponse(status: false, data: 'Error: $e');
    }
  }

  // 6. DELETE PRODUK (Perbaikan: Tambah Try-Catch & Logika JSON)
  Future<ApiResponse> deleteProduk(String id) async {
    final url = Uri.parse('$_baseUrl/produk/$id');
    try {
      final headers = await _getAuthHeaders();
      final response = await http.delete(url, headers: headers);

      if (response.statusCode == 200) {
        return ApiResponse.fromJson(json.decode(response.body));
      }
      return ApiResponse(
        status: false,
        data: 'Gagal Delete: ${response.statusCode}',
      );
    } catch (e) {
      return ApiResponse(status: false, data: 'Error: $e');
    }
  }
}
