import 'package:flutter/material.dart';
import '../models/api_response.dart';
import '../models/produk.dart';
import '../services/api_service.dart';

class ProdukFormPage extends StatefulWidget {
  final Produk?
  produk; // Opsional: Jika null = Mode Tambah, Jika ada = Mode Edit
  const ProdukFormPage({super.key, this.produk});

  @override
  State<ProdukFormPage> createState() => _ProdukFormPageState();
}

class _ProdukFormPageState extends State<ProdukFormPage> {
  final _apiService = ApiService();
  final _kodeController = TextEditingController();
  final _namaController = TextEditingController();
  final _hargaController = TextEditingController();
  final _stokController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _kategoriIdController = TextEditingController();
  final _imageUrlController =
      TextEditingController(); // Controller untuk URL Gambar

  bool _isEdit = false;
  bool _isLoading = false; // Untuk status loading tombol simpan

  @override
  void initState() {
    super.initState();
    if (widget.produk != null) {
      _isEdit = true;
      _kodeController.text = widget.produk!.kodeProduk;
      _namaController.text = widget.produk!.namaProduk;
      _hargaController.text = widget.produk!.harga.toString();
      _stokController.text = widget.produk!.stok.toString();
      _deskripsiController.text = widget.produk!.deskripsi ?? '';
      _kategoriIdController.text = widget.produk!.kategoriId?.toString() ?? '';
      _imageUrlController.text = widget.produk!.imageUrl ?? '';
    }
  }

  Future<void> _submit() async {
    if (_kodeController.text.isEmpty || _namaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kode dan Nama wajib diisi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true); // Mulai loading

    final produk = Produk(
      id: _isEdit ? widget.produk!.id : null,
      kodeProduk: _kodeController.text,
      namaProduk: _namaController.text,
      harga: int.tryParse(_hargaController.text) ?? 0,
      stok: int.tryParse(_stokController.text) ?? 0,
      deskripsi: _deskripsiController.text,
      kategoriId: int.tryParse(_kategoriIdController.text),
      imageUrl: _imageUrlController.text, // Kirim URL Gambar
    );

    ApiResponse response;

    try {
      if (_isEdit) {
        response = await _apiService.updateProduk(
          widget.produk!.id.toString(),
          produk,
        );
      } else {
        response = await _apiService.createProduk(produk);
      }

      setState(() => _isLoading = false); // Selesai loading

      if (response.status) {
        if (!mounted) return;
        Navigator.pop(context, true); // Kembali ke list dengan sinyal refresh
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.data), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC), // Background Pink Muda
      appBar: AppBar(
        backgroundColor: Colors.pink,
        elevation: 0,
        title: Text(
          _isEdit ? 'Edit Produk' : 'Tambah Produk',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 1. IMAGE PREVIEW SECTION
            _buildImagePreview(),

            const SizedBox(height: 20),

            // 2. FORM CARD
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildLabel("Informasi Utama"),
                    const SizedBox(height: 10),
                    _buildModernTextField(
                      controller: _kodeController,
                      label: "Kode Produk",
                      icon: Icons.qr_code,
                    ),
                    const SizedBox(height: 15),
                    _buildModernTextField(
                      controller: _namaController,
                      label: "Nama Produk",
                      icon: Icons.shopping_bag,
                    ),
                    const SizedBox(height: 15),

                    // Baris Harga & Stok
                    Row(
                      children: [
                        Expanded(
                          child: _buildModernTextField(
                            controller: _hargaController,
                            label: "Harga (Rp)",
                            icon: Icons.attach_money,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildModernTextField(
                            controller: _stokController,
                            label: "Stok",
                            icon: Icons.inventory,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),
                    _buildLabel("Detail Tambahan"),
                    const SizedBox(height: 10),

                    _buildModernTextField(
                      controller: _kategoriIdController,
                      label: "ID Kategori (Angka)",
                      icon: Icons.category,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 15),

                    // Input URL Gambar
                    _buildModernTextField(
                      controller: _imageUrlController,
                      label: "Link Gambar (URL)",
                      icon: Icons.image,
                      onChanged: (value) {
                        setState(
                          () {},
                        ); // Refresh UI untuk update preview gambar
                      },
                    ),
                    const SizedBox(height: 15),

                    _buildModernTextField(
                      controller: _deskripsiController,
                      label: "Deskripsi Produk",
                      icon: Icons.description,
                      maxLines: 3,
                    ),

                    const SizedBox(height: 30),

                    // TOMBOL SIMPAN
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "SIMPAN PRODUK",
                                style: TextStyle(
                                  color: Colors.white,
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
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---

  // Widget untuk Preview Gambar
  Widget _buildImagePreview() {
    return Center(
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.pink.shade100, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: _imageUrlController.text.isNotEmpty
              ? Image.network(
                  _imageUrlController.text,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, color: Colors.red, size: 40),
                        SizedBox(height: 5),
                        Text(
                          "Link Error",
                          style: TextStyle(fontSize: 12, color: Colors.red),
                        ),
                      ],
                    );
                  },
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add_a_photo, color: Colors.pinkAccent, size: 40),
                    SizedBox(height: 5),
                    Text("Preview Foto", style: TextStyle(color: Colors.grey)),
                  ],
                ),
        ),
      ),
    );
  }

  // Label Section
  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.pink.shade700,
        ),
      ),
    );
  }

  // Widget TextField Modern (Sama dengan Login/Regis)
  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
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
