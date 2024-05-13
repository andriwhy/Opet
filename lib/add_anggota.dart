import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'anggota_detail_page.dart';

class AddAnggotaPage extends StatelessWidget {
  final TextEditingController nomorIndukController = TextEditingController();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();
  final TextEditingController tanggalLahirController = TextEditingController();
  final TextEditingController teleponController = TextEditingController();

  final storage = GetStorage();

  Future<void> _addAnggota(BuildContext context) async {
    final String token = storage.read('token');
    final String baseUrl = 'https://mobileapis.manpits.xyz/api';

    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      headers: {
        'Authorization': 'Bearer $token',
      },
    ));

    try {
      FormData formData = FormData.fromMap({
        'nomor_induk': nomorIndukController.text,
        'nama': namaController.text,
        'alamat': alamatController.text,
        'tgl_lahir': tanggalLahirController.text,
        'telepon': teleponController.text,
      });

      final response = await dio.post(
        '/anggota',
        data: formData,
      );

      if (response.statusCode == 200) {
        final idAnggotaBaru = response.data['id'];
        // Save the ID of the newly added anggota to local storage
        storage.write('lastAddedAnggotaId', idAnggotaBaru);
        // Clear input fields after successfully adding anggota
        nomorIndukController.clear();
        namaController.clear();
        alamatController.clear();
        tanggalLahirController.clear();
        teleponController.clear();
        // Show success dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Anggota Added Successfully'),
            content: Text('Anggota has been successfully added!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add anggota. Please try again.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add anggota: $e'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _displayAnggotaData(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(),
      ),
    );

    final String token = storage.read('token');
    final String baseUrl = 'https://mobileapis.manpits.xyz/api';
    final int idAnggota = storage.read('lastAddedAnggotaId');

    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      headers: {
        'Authorization': 'Bearer $token',
      },
    ));

    try {
      final response = await dio.get('/anggota/$idAnggota');

      if (response.statusCode == 200) {
        Navigator.of(context).pop();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnggotaDetailPage(anggotaData: response.data),
          ),
        );
      } else {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Failed to fetch anggota data: ${response.statusCode}'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to fetch anggota data: $e'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Anggota'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nomorIndukController,
              decoration: InputDecoration(
                labelText: 'Nomor Induk',
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: namaController,
              decoration: InputDecoration(
                labelText: 'Nama',
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: alamatController,
              decoration: InputDecoration(
                labelText: 'Alamat',
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: tanggalLahirController,
              decoration: InputDecoration(
                labelText: 'Tanggal Lahir (YYYY-MM-DD)',
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: teleponController,
              decoration: InputDecoration(
                labelText: 'Telepon',
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () => _addAnggota(context),
              child: Text('Add Anggota'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () => _displayAnggotaData(context),
              child: Text('Display Anggota Data'),
            ),
          ],
        ),
      ),
    );
  }
}
