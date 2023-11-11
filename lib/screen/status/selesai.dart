import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:kurir_dapur_mamak_arvin/api/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Page3 extends StatefulWidget {
  @override
  State<Page3> createState() => _Page3State();
}

class _Page3State extends State<Page3> {
  // final StreamController<List>? streamController = StreamController();
  // final StreamController<List>? streamctrl = StreamController();
  // final StreamController<List>? streamer = StreamController();

  @override
  void initState() {
    _selesai();
    _getdata();
    super.initState();
  }

  Future<List<dynamic>?> _selesai() async {
    var result = await http.get(
        Uri.parse(BaseURL.history + idUser.toString() + "&status=selesai"));
    var data = json.decode(result.body)['data'];

    return data;
  }

  Future<void> _refreshData() async {
    // Fetch data again and update the UI
    setState(() {});
  }

  String? username, idUser;
  _getdata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Mengambil data dengan kunci 'nama'
    // Mengambil data dengan kunci 'username'
    username = prefs.getString('username');
    idUser = prefs.getString('idUser');
    setState(() {});
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: FutureBuilder<List<dynamic>?>(
          future: _selesai(), // Call _statusSedang here
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No data available.'));
            } else {
              return RefreshIndicator(
                onRefresh: _refreshData,
                child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var item = snapshot.data![index];
                    return Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: ListTile(
                            onTap: () {
                              _showDialog(context, item);
                            },
                            leading: CircleAvatar(
                              backgroundColor: _randomColor(),
                              child: Icon(
                                Icons.person,
                                size: 32,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              item['nama_pelanggan'] +
                                  " #" +
                                  item['id_pesanan'],
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              item['alamat_pelanggan'],
                              softWrap: true,
                            ),
                            trailing: Text(item['status_pesanan'])));
                  },
                ),
              );
            }
          },
        ),
      ),
    );
  }

  void _showDialog(BuildContext context, dynamic item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Detail Transaksi"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Nama: ${item['nama_pelanggan']}"),
              Text("Invoice: # ${item['id_pesanan']}"),
              Text("Total: Rp. ${item['total_transaksi']}"),
              Text("Alamat: ${item['alamat_pelanggan']}"),
              // ... tambahkan informasi lain sesuai kebutuhan
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                // ... aksi lainnya
                Navigator.pop(context);
              },
              child: Text("Tutup"),
            ),
          ],
        );
      },
    );
  }

  Color _randomColor() {
    final random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }
}
