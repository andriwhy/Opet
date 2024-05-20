import 'package:flutter/material.dart';
//import 'package:get_storage/get_storage.dart';
import 'package:deapps/login_page.dart';
import 'package:deapps/home_page.dart';
import 'package:deapps/signup_page.dart';
import 'package:deapps/profile.dart';
import 'package:deapps/add_anggota.dart';
import 'package:deapps/edit_anggota.dart';
//import 'anggota_detail_page.dart'; // Import halaman detail anggota

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Opet',
      routes: {
        '/': (context) => LoginPage(),
        '/home': (context) => HomePage(),
        '/signup': (context) => SignUpPage(),
        '/profile': (context) => ProfilePage(),
        '/add': (context) => AddAnggotaPage(),
        '/edit': (context) => EditAnggotaPage(),
        //// Tambahkan rute untuk halaman detail anggota
      },
      // onGenerateRoute: (settings) {
      //   if (settings.name == '/anggota_detail') {
      //     // Ekstrak anggotaId dari argumen
      //     final Map<String, dynamic>? args =
      //         settings.arguments as Map<String, dynamic>?;
      //     final int? anggotaId = args?['anggotaId'] as int?;

      //     // Periksa jika anggotaId tidak null
      //     if (anggotaId != null) {
      //       // Buat AnggotaDetailPage dengan anggotaId yang dilewatkan
      //       return MaterialPageRoute(
      //         builder: (context) => AnggotaDetailPage(anggotaId: anggotaId),
      //       );
      //     }
      //   }
      //   // Handle other routes here
      // },
      debugShowCheckedModeBanner: false,
    );
  }
}
