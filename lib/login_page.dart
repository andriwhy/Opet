

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'home_page.dart';
import 'signup_page.dart';

class LoginPage extends StatelessWidget {
  final storage = GetStorage();

  // Deklarasikan kontroler untuk TextField
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void login(BuildContext context) async {
    final dio = Dio();
    try {
      final response = await dio.post(
        'https://mobileapis.manpits.xyz/api/login',
        data: {
          'email':
              emailController.text, // Menggunakan nilai dari TextField email
          'password': passwordController
              .text, // Menggunakan nilai dari TextField password
        },
      );

      // Handle response here
      print(response.data);
      if (response.statusCode == 200) {
        final storage = GetStorage();
        storage.write('token', response.data['data']['token']);
        storage.write('user', response.data['data']['user']);
        final user = storage.read('user');
        print('user from login: $user');

        // Login berhasil
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else if (response.statusCode == 400 &&
          response.data['message'] == 'Email not registered') {
        // Email belum terdaftar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email is not registered. Please sign up first.'),
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        // Kasus lainnya
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to login. Please try again.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } on DioError catch (e) {
      // Handle DioError
      print('Error: ${e.response?.statusCode} - ${e.response?.data}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to login. Please try again.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFFB9898)], // Putih ke #FB9898
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 50),
                Image.asset(
                  'assets/images/login.png',
                  height: 200,
                ),
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller:
                        emailController, // Menghubungkan kontroler ke TextField
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller:
                        passwordController, // Menghubungkan kontroler ke TextField
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    obscureText: true,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Panggil metode login
                    login(context);
                  },
                  child: Text('Login'),
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpPage()),
                    );
                  },
                  child: Text('Sign Up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
