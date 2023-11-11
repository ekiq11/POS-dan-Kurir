import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:kurir_dapur_mamak_arvin/api/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Page1 extends StatefulWidget {
  @override
  State<Page1> createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  // final StreamController<List>? streamController = StreamController();
  // final StreamController<List>? streamctrl = StreamController();
  // final StreamController<List>? streamer = StreamController();

  @override
  void initState() {
    _belumdikirim();
    _getdata();
    super.initState();
  }

  Future<List<dynamic>?> _belumdikirim() async {
    var result = await http.get(Uri.parse(BaseURL.belumDiantar));
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
          future: _belumdikirim(), // Call _statusSedang here
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
                      child: Card(
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
                            trailing: IconButton(
                                onPressed: () async {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("Konfirmasi"),
                                        content: Text(
                                            "Apakah Anda yakin ingin mengantar pesanan ini ?"),
                                        actions: [
                                          ElevatedButton(
                                            onPressed: () async {
                                              try {
                                                final response =
                                                    await http.post(
                                                  Uri.parse(BaseURL.antar),
                                                  body: {
                                                    "id_pesanan":
                                                        item['id_pesanan'],
                                                    "id_kurir":
                                                        idUser.toString(),
                                                  },
                                                );
                                                print(idUser);
                                                print(item['id_pesanan']);
                                                if (response.statusCode ==
                                                    200) {
                                                  _refreshData();
                                                } else {
                                                  _refreshData();
                                                  // Gagal mengirim data
                                                  // Tambahkan logika untuk menanggapi respon yang tidak berhasil di sini
                                                  print(
                                                      "Gagal mengirim data. Status code: ${response.statusCode}");
                                                }
                                              } catch (error) {
                                                // Terjadi kesalahan dalam koneksi atau respons
                                                // Tambahkan logika untuk menanggapi kesalahan di sini
                                                print(
                                                    "Terjadi kesalahan: $error");
                                              }
                                              Navigator.pop(context);
                                            },
                                            child: Text("Ya"),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text("Tidak"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                icon: Icon(Icons.send))),
                      ),
                    );
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

// Function to send data to the database
}
