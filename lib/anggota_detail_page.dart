import 'package:flutter/material.dart';

class AnggotaDetailPage extends StatelessWidget {
  final Map<String, dynamic> anggotaData;

  const AnggotaDetailPage({Key? key, required this.anggotaData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Anggota Detail'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nomor Induk: ${anggotaData['nomor_induk']}'),
            Text('Nama: ${anggotaData['nama']}'),
            Text('Alamat: ${anggotaData['alamat']}'),
            Text('Tanggal Lahir: ${anggotaData['tgl_lahir']}'),
            Text('Telepon: ${anggotaData['telepon']}'),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                // Navigasi ke halaman sebelumnya
                Navigator.pop(context);
              },
              child: Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
