import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

class JenisTransaksiPage extends StatefulWidget {
  @override
  _JenisTransaksiPageState createState() => _JenisTransaksiPageState();
}

class _JenisTransaksiPageState extends State<JenisTransaksiPage> {
  final storage = GetStorage();
  List<dynamic> jenisTransaksiList = [];

  @override
  void initState() {
    super.initState();
    _fetchJenisTransaksi();
  }

  Future<void> _fetchJenisTransaksi() async {
    final String token = storage.read('token');
    final String baseUrl = 'https://mobileapis.manpits.xyz/api';

    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      headers: {
        'Authorization': 'Bearer $token',
      },
    ));

    try {
      final response = await dio.get('/jenistransaksi');

      if (response.statusCode == 200) {
        setState(() {
          jenisTransaksiList = response.data['data'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fetch jenis transaksi.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to fetch jenis transaksi. Please try again.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jenis Transaksi'),
      ),
      body: ListView.builder(
        itemCount: jenisTransaksiList.length,
        itemBuilder: (context, index) {
          final jenisTransaksi = jenisTransaksiList[index];
          return ListTile(
            title: Text(jenisTransaksi['nama']),
            subtitle: Text('ID: ${jenisTransaksi['id']}'),
          );
        },
      ),
    );
  }
}
