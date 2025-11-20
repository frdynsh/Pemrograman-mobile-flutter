import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/produk.dart';
import '../services/api_service.dart';
import 'produk_form_page.dart';

class ProdukListPage extends StatefulWidget {
  const ProdukListPage({super.key});
  @override
  State<ProdukListPage> createState() => _ProdukListPageState();
}

class _ProdukListPageState extends State<ProdukListPage> {
  final ApiService _apiService = ApiService();

  // Variabel untuk menampung data
  List<Produk> _allProduk = []; // Data asli dari API
  List<Produk> _filteredProduk = []; // Data hasil pencarian
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProduk();
  }

  // Fungsi Load Data (Diupdate untuk mendukung Search)
  Future<void> _loadProduk() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final list = await _apiService.getProduk();
      setState(() {
        _allProduk = list;
        _filteredProduk = list; // Awalnya tampilkan semua
        _isLoading = false;
      });
    } catch (e) {
      if (e.toString().contains('TOKEN_EXPIRED')) {
        _logout();
      }
      setState(() {
        _isLoading = false;
      });
      // Opsional: Tampilkan error di snackbar
    }
  }

  // Fungsi Filter Pencarian
  void _runFilter(String keyword) {
    List<Produk> results = [];
    if (keyword.isEmpty) {
      results = _allProduk;
    } else {
      results = _allProduk
          .where(
            (produk) =>
                produk.namaProduk.toLowerCase().contains(
                  keyword.toLowerCase(),
                ) ||
                produk.kodeProduk.toLowerCase().contains(keyword.toLowerCase()),
          )
          .toList();
    }

    setState(() {
      _filteredProduk = results;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _delete(Produk produk) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Produk?'),
        content: Text('Yakin ingin menghapus "${produk.namaProduk}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _isLoading = true;
      });
      await _apiService.deleteProduk(produk.id.toString());
      _loadProduk(); // Refresh data
    }
  }

  Future<void> _navigateToForm({Produk? produk}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProdukFormPage(produk: produk)),
    );
    if (result == true) _loadProduk();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC), // Background Pink Muda
      appBar: AppBar(
        backgroundColor: Colors.pink,
        elevation: 0,
        title: const Text(
          'Daftar Produk',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. SEARCH BAR AREA
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            decoration: const BoxDecoration(
              color: Colors.pink,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _runFilter(value),
              decoration: InputDecoration(
                hintText: "Cari nama atau kode produk...",
                prefixIcon: const Icon(Icons.search, color: Colors.pink),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 2. LIST PRODUK AREA
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.pink),
                  )
                : _filteredProduk.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredProduk.length,
                    itemBuilder: (context, index) {
                      return _buildProductCard(_filteredProduk[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(),
        backgroundColor: Colors.pink,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Widget Tampilan Kosong
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.search_off, size: 70, color: Colors.grey),
          SizedBox(height: 10),
          Text("Produk tidak ditemukan", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // Widget Kartu Produk Modern
  Widget _buildProductCard(Produk produk) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () => _navigateToForm(produk: produk),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // A. Gambar / Placeholder (Kiri)
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.pink[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: produk.imageUrl != null && produk.imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          produk.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, error, stack) => const Icon(
                            Icons.broken_image,
                            color: Colors.pinkAccent,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.inventory_2_outlined,
                        color: Colors.pinkAccent,
                        size: 35,
                      ),
              ),

              const SizedBox(width: 16),

              // B. Detail Produk (Tengah)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      produk.namaProduk,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Kode: ${produk.kodeProduk}",
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          "Rp ${produk.harga}",
                          style: const TextStyle(
                            color: Colors.pink,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: produk.stok > 0
                                ? Colors.green[50]
                                : Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Stok: ${produk.stok}",
                            style: TextStyle(
                              fontSize: 11,
                              color: produk.stok > 0
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // C. Tombol Hapus (Kanan)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () => _delete(produk),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
