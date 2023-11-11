import 'package:flutter/material.dart';
import 'package:kurir_dapur_mamak_arvin/screen/login.dart';
import 'package:kurir_dapur_mamak_arvin/screen/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Check if the user is logged in, if yes, go to Home, else go to LoginPage
      home: FutureBuilder<bool>(
        future: _getdata(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError || !snapshot.data!) {
            return const LoginPage();
          } else {
            return const HomePage();
          }
        },
      ),
    );
  }

  // Method to check if the user is logged in
  Future<bool> _getdata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Mengambil data dengan kunci 'nama'
    // Mengambil data dengan kunci 'username'
    String? username = prefs.getString('username');
    String? idUser = prefs.getString('idUser');

    // Check if both username and idUser are not null
    return username != null && idUser != null;
  }
}
