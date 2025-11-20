import 'package:flutter/material.dart';
import 'weather_page.dart'; // Impor halaman produk kita

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Produk',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: WeatherPage(), // Mulai aplikasi di halaman ProdukPage
      debugShowCheckedModeBanner: false,
    );
  }
}
