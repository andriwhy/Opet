import 'package:flutter/material.dart';
import 'package:deapps/login_page.dart';
import 'package:deapps/home_page.dart';
import 'package:deapps/signup_page.dart';
import 'package:deapps/profile.dart';
import 'package:deapps/add_anggota.dart';
import 'package:deapps/edit_anggota.dart';
import 'package:deapps/add_transaksi.dart'
    as addTransaksi; // Use alias to avoid naming conflict

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
        '/add_transaksi': (context) =>
            addTransaksi.AddTransaksiPage(), // Updated with prefix
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
