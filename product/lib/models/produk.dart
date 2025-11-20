class Produk {
  final int? id;
  final String kodeProduk;
  final String namaProduk;
  final int harga;
  final int stok; // Penting untuk UI validasi stok habis
  final String? deskripsi; // Opsional (bisa null)
  final String?
  imageUrl; // Opsional (bisa null), nanti UI pakai placeholder jika null
  final int? kategoriId; // Opsional

  Produk({
    this.id,
    required this.kodeProduk,
    required this.namaProduk,
    required this.harga,
    required this.stok,
    this.deskripsi,
    this.imageUrl,
    this.kategoriId,
  });

  factory Produk.fromJson(Map<String, dynamic> json) {
    return Produk(
      // 1. ID (Aman)
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()),

      // 2. STRING WAJIB (Anti-Crash)
      // Kita pakai .toString() ?? '' agar jika null, dia jadi string kosong, bukan error
      kodeProduk: json['kode_produk']?.toString() ?? '',
      namaProduk: json['nama_produk']?.toString() ?? 'Tanpa Nama',

      // 3. ANGKA (Aman dari String/Int)
      harga: int.tryParse(json['harga'].toString()) ?? 0,
      stok: int.tryParse(json['stok'].toString()) ?? 0,

      // 4. STRING OPSIONAL (Boleh Null)
      deskripsi: json['deskripsi']?.toString(),
      imageUrl: json['image_url']?.toString(),

      // 5. ID KATEGORI
      kategoriId: int.tryParse(json['kategori_id'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kode_produk': kodeProduk,
      'nama_produk': namaProduk,
      'harga': harga,
      'stok': stok,
      'deskripsi': deskripsi,
      'image_url': imageUrl,
      'kategori_id': kategoriId,
    };
  }
}
