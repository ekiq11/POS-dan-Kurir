// ignore_for_file: prefer_const_constructors

import 'package:bitcoin_icons/bitcoin_icons.dart';
import 'package:flutter/material.dart';
import 'package:kurir_dapur_mamak_arvin/screen/login.dart';

import 'package:kurir_dapur_mamak_arvin/screen/status/belum.dart';
import 'package:kurir_dapur_mamak_arvin/screen/status/sedang.dart';
import 'package:kurir_dapur_mamak_arvin/screen/status/selesai.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Define the list of pages to be displayed based on the index
  final List<Widget> _pages = [
    // Add your different pages here
    Page1(),
    Page2(),
    Page3(),
  ];
  String? username, idUser;
  _getdata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Mengambil data dengan kunci 'nama'
    // Mengambil data dengan kunci 'username'
    username = prefs.getString('username');
    idUser = prefs.getString('idUser');
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getdata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Selamat Datang " + username.toString(),
              style: TextStyle(fontSize: 14),
            ),
            IconButton(
                onPressed: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.remove('username');
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext ctx) => const LoginPage()));
                },
                icon: Icon(Icons.logout))
          ],
        ),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.red,
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        // ignore: prefer_const_literals_to_create_immutables
        items: [
          BottomNavigationBarItem(
            backgroundColor: Colors.red,
            icon: Icon(BitcoinIcons.block_outline, color: Colors.red),
            label: 'Belum dikirim',
          ),
          const BottomNavigationBarItem(
            backgroundColor: Colors.red,
            icon: Icon(Icons.send_outlined, color: Colors.red),
            label: 'Sedang dikirim',
          ),
          const BottomNavigationBarItem(
            backgroundColor: Colors.red,
            icon: Icon(
              Icons.done_all,
              color: Colors.red,
            ),
            label: 'Selesai',
          ),
        ],
      ),
    );
  }
}
