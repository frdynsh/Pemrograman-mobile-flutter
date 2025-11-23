class Produk {
  // 1. Properti (variabel) yang akan dimiliki setiap produk
  final String nama;
  final String deskripsi;
  final int harga;
  final String imageUrl;

  // 2. Konstruktor (cara membuat objek produk)
  Produk({
    required this.nama,
    required this.deskripsi,
    required this.harga,
    required this.imageUrl,
  });
}
