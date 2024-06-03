import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

class AddTransaksiPage extends StatefulWidget {
  @override
  _AddTransaksiPageState createState() => _AddTransaksiPageState();
}

class _AddTransaksiPageState extends State<AddTransaksiPage> {
  List<dynamic> _jenisTransaksiList = [];
  List<dynamic> _anggotaList = [];
  int? _selectedJenisTransaksi;
  int? _selectedAnggota;
  TextEditingController _nominalController = TextEditingController();
  final _storage = GetStorage();
  final _dio = Dio();
  final _apiUrl = 'https://mobileapis.manpits.xyz/api';

  @override
  void initState() {
    super.initState();
    _fetchJenisTransaksi();
    _fetchAnggota();
  }

  void _fetchJenisTransaksi() async {
    try {
      final response = await _dio.get(
        '$_apiUrl/jenistransaksi',
        options: Options(
          headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
        ),
      );
      setState(() {
        _jenisTransaksiList = response.data['data']['jenistransaksi'] ?? [];
      });
    } catch (e) {
      print('Error fetching jenis transaksi: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mendapatkan jenis transaksi'),
        ),
      );
    }
  }

  void _fetchAnggota() async {
    try {
      final response = await _dio.get(
        '$_apiUrl/anggota',
        options: Options(
          headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
        ),
      );
      setState(() {
        _anggotaList = response.data['data']['anggotas'] ?? [];
      });
    } catch (e) {
      print('Error fetching anggota: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mendapatkan daftar anggota'),
        ),
      );
    }
  }

  Future<void> _saveTransaction() async {
    if (_selectedAnggota == null ||
        _selectedJenisTransaksi == null ||
        _nominalController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mohon lengkapi semua data transaksi'),
        ),
      );
      return;
    }

    try {
      final response = await _dio.post(
        '$_apiUrl/tabungan',
        data: {
          'anggota_id': _selectedAnggota,
          'trx_id': _selectedJenisTransaksi,
          'trx_nominal': _nominalController.text,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${_storage.read('token')}',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Transaction saved successfully: ${response.data}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transaksi berhasil disimpan'),
          ),
        );
        Navigator.pop(context, true); // Mengirimkan nilai balik true
      } else {
        print('Failed to save transaction: ${response.data}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan transaksi. Mohon coba lagi.'),
          ),
        );
      }
    } catch (e) {
      print('Error saving transaction: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan. Mohon coba lagi.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Transaksi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nama Anggota',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: _selectedAnggota,
              items: _anggotaList.map((anggota) {
                return DropdownMenuItem<int>(
                  value: anggota['id'],
                  child: Text(anggota['nama']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedAnggota = value;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Pilih nama anggota',
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Jenis Transaksi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: _selectedJenisTransaksi,
              items: _jenisTransaksiList.map((jenisTransaksi) {
                return DropdownMenuItem<int>(
                  value: jenisTransaksi['id'],
                  child: Text(jenisTransaksi['trx_name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedJenisTransaksi = value;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Pilih jenis transaksi',
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Nominal Transaksi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: _nominalController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Masukkan nominal transaksi',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveTransaction,
              child: Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
