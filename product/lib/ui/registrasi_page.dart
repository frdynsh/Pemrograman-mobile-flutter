import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RegistrasiPage extends StatefulWidget {
  const RegistrasiPage({super.key});
  @override
  State<RegistrasiPage> createState() => _RegistrasiPageState();
}

class _RegistrasiPageState extends State<RegistrasiPage> {
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _apiService = ApiService();

  // --- LOGIKA (TETAP SAMA SEPERTI SEBELUMNYA) ---
  void _showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: Colors.pink, // Ubah warna loading jadi pink
        ),
      ),
    );
  }

  void _hideLoading() {
    Navigator.pop(context);
  }

  void _doRegistrasi() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password tidak sama!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    _showLoading();

    try {
      final response = await _apiService.registrasi(
        _namaController.text,
        _emailController.text,
        _passwordController.text,
      );

      _hideLoading();

      if (!mounted) return;

      if (response.status) {
        // Sukses
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.data), backgroundColor: Colors.green),
        );
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        // Gagal dari server
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.data), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      _hideLoading();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // --- UI MODERN (PINK THEME) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background pink sangat muda agar terlihat bersih
      backgroundColor: const Color(0xFFFCE4EC),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. Header / Logo
              const Icon(
                Icons.shopping_bag_outlined, // Ikon Toko
                size: 80,
                color: Colors.pink,
              ),
              const SizedBox(height: 10),
              const Text(
                "Buat Akun Baru",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink,
                ),
              ),
              const Text(
                "Silakan lengkapi data diri Anda",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),

              // 2. Card Form
              Card(
                elevation: 4, // Efek bayangan
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Input Nama
                      _buildModernTextField(
                        controller: _namaController,
                        label: "Nama Lengkap",
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 16),

                      // Input Email
                      _buildModernTextField(
                        controller: _emailController,
                        label: "Alamat Email",
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      // Input Password
                      _buildModernTextField(
                        controller: _passwordController,
                        label: "Password",
                        icon: Icons.lock_outline,
                        isPassword: true,
                      ),
                      const SizedBox(height: 16),

                      // Input Konfirmasi Password
                      _buildModernTextField(
                        controller: _confirmPasswordController,
                        label: "Ulangi Password",
                        icon: Icons.lock_reset,
                        isPassword: true,
                      ),
                      const SizedBox(height: 24),

                      // Tombol Daftar
                      SizedBox(
                        width: double.infinity, // Lebar penuh
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _doRegistrasi,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink, // Warna Tombol
                            foregroundColor: Colors.white, // Warna Teks
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            "DAFTAR SEKARANG",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 3. Footer Link ke Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Sudah punya akun? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text(
                      "Masuk disini",
                      style: TextStyle(
                        color: Colors.pink,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget untuk membuat TextField yang seragam
  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.pinkAccent), // Ikon warna pink
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none, // Hilangkan border default
        ),
        filled: true,
        fillColor: Colors.pink[50]!.withOpacity(0.5), // Latar input pink pudar
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),

        // Style saat diklik
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.pink, width: 2),
        ),
      ),
    );
  }
}
