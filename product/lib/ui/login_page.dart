import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiService = ApiService();

  // --- LOGIKA (TETAP SAMA) ---
  void _showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.pink), // Loading Pink
      ),
    );
  }

  void _hideLoading() {
    Navigator.pop(context);
  }

  Future<void> _doLogin() async {
    _showLoading();

    try {
      final response = await _apiService.login(
        _emailController.text,
        _passwordController.text,
      );

      _hideLoading();

      if (response.status) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', response.token);
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/produk');
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.token), // Pesan error dari server
            backgroundColor: Colors.red, // Merah untuk error
          ),
        );
      }
    } catch (e) {
      _hideLoading();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // --- UI MODERN (PINK THEME) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC), // Background Pink Muda
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. Header / Logo
              const Icon(
                Icons.storefront_outlined, // Ikon Toko
                size: 80,
                color: Colors.pink,
              ),
              const SizedBox(height: 10),
              const Text(
                "Selamat Datang",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink,
                ),
              ),
              const Text(
                "Masuk untuk mulai berbelanja",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),

              // 2. Card Form
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Input Email
                      _buildModernTextField(
                        controller: _emailController,
                        label: "Email",
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
                      const SizedBox(height: 24),

                      // Tombol Masuk
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _doLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            "MASUK",
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

              // 3. Footer Link ke Registrasi
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Belum punya akun? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/registrasi');
                    },
                    child: const Text(
                      "Daftar disini",
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

  // Helper Widget (Sama persis dengan Registrasi Page agar konsisten)
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
        prefixIcon: Icon(icon, color: Colors.pinkAccent),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.pink[50]!.withOpacity(0.5),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.pink, width: 2),
        ),
      ),
    );
  }
}
