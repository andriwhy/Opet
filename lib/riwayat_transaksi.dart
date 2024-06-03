import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

class RiwayatTransaksiPage extends StatefulWidget {
  @override
  _RiwayatTransaksiPageState createState() => _RiwayatTransaksiPageState();
}

class _RiwayatTransaksiPageState extends State<RiwayatTransaksiPage> {
  final _storage = GetStorage();
  final _dio = Dio();
  final _apiUrl = 'https://mobileapis.manpits.xyz/api';
  List<Map<String, dynamic>> _transactionList = [];
  bool _isLoading = true;
  late int anggotaId;
  String? namaAnggota;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments != null && arguments is Map<String, dynamic>) {
      anggotaId = arguments['id'];
      print('Anggota ID: $anggotaId'); // Log anggotaId
      _fetchTransactions();
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Anggota ID tidak ditemukan'),
        ),
      );
    }
  }

  Future<void> _fetchTransactions() async {
    try {
      final token = _storage.read('token');
      if (token == null) {
        throw 'Token tidak ditemukan';
      }

      final response = await _dio.get(
        '$_apiUrl/tabungan/$anggotaId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      print('API Response: ${response.data}'); // Log API response

      // Ambil data tabungan dan nama anggota dari response
      final data = response.data['data'];
      List<dynamic> transactions = data['tabungan'] ?? [];
      namaAnggota = data['nama_anggota'];

      setState(() {
        _transactionList = List<Map<String, dynamic>>.from(transactions);
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching transactions: $e'); // Log error
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mendapatkan riwayat transaksi: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Transaksi'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _buildTransactionList(),
    );
  }

  Widget _buildTransactionList() {
    if (_transactionList.isEmpty) {
      return Center(child: Text('Tidak ada riwayat transaksi'));
    }

    return ListView.builder(
      itemCount: _transactionList.length,
      itemBuilder: (context, index) {
        final transaction = _transactionList[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: ListTile(
            title: Text('Transaction ID: ${transaction['id']}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'Transaction Name: ${transaction['trx_id']}'), // assuming trx_id maps to transaction name
                Text('Amount: ${transaction['trx_nominal']}'),
                Text('Date: ${transaction['trx_tanggal']}'),
                if (namaAnggota != null) Text('Nama Anggota: $namaAnggota'),
              ],
            ),
          ),
        );
      },
    );
  }
}
