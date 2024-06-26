import 'package:flutter/material.dart';
import 'profile.dart'; // Import file profile.dart
import 'add_anggota.dart'; // Import file add_anggota.dart
import 'edit_anggota.dart'; // Import file edit_anggota.dart
import 'add_transaksi.dart'; // Import file add_transaksi.dart
import 'riwayat_transaksi.dart'; // Import file riwayat_transaksi.dart
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _storage = GetStorage();
  final _dio = Dio();
  final _apiUrl = 'https://mobileapis.manpits.xyz/api';
  List<Map<String, dynamic>> _anggotaList = [];
  int _selectedIndex = 0; // Untuk melacak indeks tab yang dipilih

  @override
  void initState() {
    super.initState();
    _fetchAnggota();
  }

  Future<void> _fetchAnggota() async {
    try {
      final response = await _dio.get(
        '$_apiUrl/anggota',
        options: Options(
          headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
        ),
      );
      List<dynamic> anggotas = response.data['data']['anggotas'] ?? [];
      List<Map<String, dynamic>> anggotaWithSaldo = [];

      for (var anggota in anggotas) {
        int anggotaId = anggota['id'];
        double saldo = await _fetchSaldo(anggotaId);
        anggotaWithSaldo.add({...anggota, 'saldo': saldo});
      }

      setState(() {
        _anggotaList = anggotaWithSaldo;
      });
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mendapatkan daftar anggota'),
        ),
      );
    }
  }

  Future<double> _fetchSaldo(int anggotaId) async {
    try {
      final response = await _dio.get(
        '$_apiUrl/saldo/$anggotaId',
        options: Options(
          headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
        ),
      );
      return response.data['data']['saldo']?.toDouble() ?? 0.0;
    } catch (e) {
      print(e);
      return 0.0;
    }
  }

  Future<void> _deleteAnggota(int id) async {
    try {
      await _dio.delete(
        '$_apiUrl/anggota/$id',
        options: Options(
          headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
        ),
      );
      _fetchAnggota();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Anggota berhasil dihapus'),
        ),
      );
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus anggota'),
        ),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddTransaksiPage()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddAnggotaPage()),
      ).then((result) {
        if (result == true) {
          _fetchAnggota(); // Refresh list after adding
        }
      });
    }
  }

  void _showAnggotaOptions(BuildContext context, Map<String, dynamic> anggota) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.account_balance_wallet),
              title: Text('Tambah Transaksi'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddTransaksiPage(),
                    settings: RouteSettings(arguments: anggota),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('Riwayat Transaksi'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RiwayatTransaksiPage(),
                    settings: RouteSettings(arguments: anggota),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit Anggota'),
              onTap: () {
                Navigator.pop(context); // Close the bottom sheet
                _showEditWarning(context, anggota);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Hapus Anggota'),
              onTap: () {
                Navigator.pop(context); // Close the bottom sheet
                _showDeleteWarning(context, anggota['id']);
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditWarning(BuildContext context, Map<String, dynamic> anggota) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Peringatan'),
          content: Text('Apakah Anda yakin ingin mengedit anggota ini?'),
          actions: <Widget>[
            TextButton(
              child: Text('Tidak'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Ya'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditAnggotaPage(),
                    settings: RouteSettings(arguments: anggota),
                  ),
                ).then((_) => _fetchAnggota());
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteWarning(BuildContext context, int anggotaId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Peringatan'),
          content: Text('Apakah Anda yakin ingin menghapus anggota ini?'),
          actions: <Widget>[
            TextButton(
              child: Text('Tidak'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Ya'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAnggota(anggotaId);
              },
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
        title: Image.asset(
          'assets/images/opet.png',
          height: 40,
          width: 120, // Perbesar lebarnya
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              // Navigasi ke halaman profil saat ikon diklik
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
        ],
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFFB9898)],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 20),
              Image.asset(
                'assets/images/groupcat.png',
                height: 150,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Search for a pet',
                    filled: true,
                    fillColor: Colors.white70,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildItem('Siena', 'assets/images/cat1.jpg'),
                    const SizedBox(width: 10), // Jarak antara box
                    _buildItem('Comcom', 'assets/images/cat2.jpg'),
                    const SizedBox(width: 10), // Jarak antara box
                    _buildItem('Nyaw', 'assets/images/cat3.png'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Customer Reviews',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildReviewBox(
                        'John Doe', 'Great pet, very friendly and playful.'),
                    const SizedBox(height: 10),
                    _buildReviewBox(
                        'Jane Smith', 'The cat is adorable, my kids love it!'),
                    const SizedBox(height: 20),
                    const Text(
                      'List Anggota',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildAnggotaList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Transaksi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: 'Tambah Anggota',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildItem(String title, String imagePath) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            width: 150,
            height: 100,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 10),
          Text(
            title, // Ganti nama pet
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            '\$100',
            style: TextStyle(
              color: Color(0xFFF5A9A9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewBox(String name, String review) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            review,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnggotaList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _anggotaList.length,
      itemBuilder: (context, index) {
        final anggota = _anggotaList[index];
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFFB9898),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            title: Text(
              anggota['nama'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
                'Telepon: ${anggota['telepon']} \nSaldo: ${anggota['saldo']}'),
            onTap: () => _showAnggotaOptions(context, anggota),
          ),
        );
      },
    );
  }
}
