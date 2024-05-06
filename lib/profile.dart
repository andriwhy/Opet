import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _storage = GetStorage();
  final _dio = Dio();
  final _apiUrl = 'https://mobileapis.manpits.xyz/api';

  String _name = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _setUserDetail();
    // getUserDetail();
  }

  void _setUserDetail() {
    final storage = GetStorage();
    final user = storage.read('user');
    print('user: $user');
    setState(() {
      _name = user['name'];
      _email = user['email'];
    });
  }

  // void getUserDetail() async {
  //   try {
  //     print('token: ');
  //     print(_storage.read('token'));
  //     final response = await _dio.get(
  //       '$_apiUrl/user',
  //       options: Options(
  //         headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
  //       ),
  //     );

  //     if (response.statusCode == 200) {
  //       setState(() {
  //         _name = response.data['data']['name'];
  //         _email = response.data['data']['email'];
  //       });
  //     } else {
  //       print('Failed to get user detail: ${response.statusCode}');
  //       // Menampilkan pesan kesalahan jika permintaan tidak berhasil
  //       _showErrorDialog('Failed to get user detail. Please try again later.');
  //     }
  //   } on DioError catch (e) {
  //     // Tangani kesalahan koneksi atau tanggapan API yang tidak berhasil
  //     print('DioError: ${e.message}');
  //     _showErrorDialog('Failed to get user detail. Please try again later.');
  //   } catch (e) {
  //     // Tangani kesalahan umum
  //     print('Error: $e');
  //     _showErrorDialog('Failed to get user detail. Please try again later.');
  //   }
  // }

  void goLogout() async {
    try {
      final response = await _dio.get(
        '$_apiUrl/logout',
        options: Options(
          headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
        ),
      );

      // Pastikan respons berisi kode status 200 OK
      if (response.statusCode == 200) {
        // Hapus semua data dari penyimpanan lokal setelah logout berhasil
        _storage.erase();
        print('200');
        // Navigasi kembali ke halaman login
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      } else {
        stderr.writeln('err not 200');
        // Menampilkan pesan kesalahan jika respons tidak berhasil
        _showErrorDialog('Failed to logout. Please try again later.');
      }
    } on DioError catch (e) {
      stderr.writeln('err dio');
      // Menampilkan pesan kesalahan jika terjadi kesalahan saat melakukan permintaan
      print('Error: $e');
      _showErrorDialog('Failed to logout. Please try again later.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: goLogout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.pinkAccent,
                child: Text(
                  _name.isNotEmpty ? _name[0].toUpperCase() : '',
                  style: const TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Name:',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              _name,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Email:',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              _email,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
