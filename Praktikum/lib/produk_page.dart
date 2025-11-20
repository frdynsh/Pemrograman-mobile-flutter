import 'package:flutter/material.dart';
import 'produk_model.dart';

// 1. Ubah dari StatelessWidget menjadi StatefulWidget
class ProdukPage extends StatefulWidget {
  const ProdukPage({super.key});

  @override
  State<ProdukPage> createState() => _ProdukPageState();
}

// 2. Buat kelas State-nya
class _ProdukPageState extends State<ProdukPage> {
  // 3. Pindahkan list data KE DALAM State
  // Kita ubah dari 'final' menjadi List biasa agar bisa diubah
  final List<Produk> products = [
    Produk(
        nama: "Kulkas A",
        deskripsi: "Kulkas 2 pintu, hemat listrik",
        harga: 2500000,
        imageUrl: "https://picsum.photos/id/10/200"),
    Produk(
        nama: "TV B",
        deskripsi: "Smart TV 50 inch, 4K",
        harga: 5000000,
        imageUrl: "https://picsum.photos/id/20/200"),
    Produk(
        nama: "Mesin Cuci C",
        deskripsi: "Front loading, 7kg",
        harga: 3500000,
        imageUrl: "https://picsum.photos/id/30/200"),
  ];

  // 4. Controller untuk TextField di dialog nanti
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();

  // 5. FUNGSI UNTUK MENAMBAH PRODUK
  void _addProduct() {
    // Ambil data dari controller
    final String nama = _namaController.text;
    final String deskripsi = _deskripsiController.text;
    final int harga = int.tryParse(_hargaController.text) ?? 0;

    if (nama.isNotEmpty && deskripsi.isNotEmpty && harga > 0) {
      // Buat produk baru
      Produk produkBaru = Produk(
        nama: nama,
        deskripsi: deskripsi,
        harga: harga,
        imageUrl: "https://picsum.photos/id/${products.length + 40}/200", // Gambar acak
      );

      // 6. INI BAGIAN PENTING: setState()
      // Kita memberi tahu Flutter bahwa ada data berubah
      // dan UI harus di-render ulang
      setState(() {
        products.add(produkBaru);
      });

      // Bersihkan controller dan tutup dialog
      _namaController.clear();
      _deskripsiController.clear();
      _hargaController.clear();
      Navigator.pop(context); // Tutup dialog
    }
  }
  
  // 7. FUNGSI UNTUK MENGHAPUS PRODUK
  void _deleteProduct(int index) {
    // Panggil setState() untuk update UI
    setState(() {
      products.removeAt(index);
    });
  }

  // 8. FUNGSI UNTUK MENAMPILKAN DIALOG TAMBAH
  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Tambah Produk Baru"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: "Nama Produk"),
              ),
              TextField(
                controller: _deskripsiController,
                decoration: const InputDecoration(labelText: "Deskripsi"),
              ),
              TextField(
                controller: _hargaController,
                decoration: const InputDecoration(labelText: "Harga"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: _addProduct, // Panggil fungsi tambah
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  // Build method (UI) sekarang ada di dalam kelas State
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Produk (Dinamis)"),
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          // Oper data DAN fungsi hapus ke ItemProduk
          return ItemProduk(
            produk: products[index],
            onDelete: () => _deleteProduct(index), // 9. Kirim fungsi hapus
          );
        },
      ),
      // 10. Tombol untuk menambah data
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog, // Panggil dialog
        tooltip: 'Tambah Produk',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// --- Widget ItemProduk (Sekarang di file yang sama) ---
// Kita modifikasi agar bisa menerima fungsi onDelete

class ItemProduk extends StatelessWidget {
  final Produk produk;
  final VoidCallback onDelete; // 11. Tambahkan parameter fungsi

  const ItemProduk({
    super.key,
    required this.produk,
    required this.onDelete, // 12. Wajibkan di konstruktor
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: Image.network(
          produk.imageUrl,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
        title: Text(produk.nama,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(produk.deskripsi),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Rp ${produk.harga}",
              style: const TextStyle(color: Colors.green, fontSize: 14),
            ),
            // 13. Tombol Hapus
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete, // Panggil fungsi yang dioper
            ),
          ],
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Anda memilih ${produk.nama}")),
          );
        },
      ),
    );
  }
}
