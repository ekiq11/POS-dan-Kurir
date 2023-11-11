import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:kurir_dapur_mamak_arvin/api/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Page2 extends StatefulWidget {
  @override
  State<Page2> createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  // final StreamController<List>? streamController = StreamController();
  // final StreamController<List>? streamctrl = StreamController();
  // final StreamController<List>? streamer = StreamController();
  _launch(url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      print("Not supported");
    }
  }

  @override
  void initState() {
    _sedangdkirim();
    _getdata();
    super.initState();
  }

  Future<List<dynamic>?> _sedangdkirim() async {
    var result = await http.get(Uri.parse(
        BaseURL.dataantar + idUser.toString() + "&status=sedang%20dikirim"));
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

  Future<void> _launchWhatsApp(String phoneNumber, String message) async {
    String url = "whatsapp://send?phone=$phoneNumber&text=$message";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      print("Could not launch $url");
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: FutureBuilder<List<dynamic>?>(
          future: _sedangdkirim(), // Call _statusSedang here
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
                            item['nama_pelanggan'] + " #" + item['id_pesanan'],
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle:
                              Text(item['alamat_pelanggan'], softWrap: true),
                          trailing: Container(
                            width: 150,
                            // Sesuaikan lebar Container sesuai kebutuhan
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.delete_sweep_outlined),
                                  color: Colors.redAccent,
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text("Konfirmasi"),
                                          content: Text(
                                              "Apakah Anda ingin membatalkan mengantar pesanan ini ?"),
                                          actions: [
                                            ElevatedButton(
                                              onPressed: () async {
                                                try {
                                                  final response =
                                                      await http.post(
                                                    Uri.parse(BaseURL.batal),
                                                    body: {
                                                      "id_pesanan":
                                                          item['id_pesanan'],
                                                      "id_kurir":
                                                          idUser.toString(),
                                                    },
                                                  );

                                                  if (response.statusCode ==
                                                      200) {
                                                    _refreshData();
                                                    // Data berhasil dikirim
                                                    // Tambahkan logika untuk menanggapi respon yang berhasil di sini
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
                                ),
                                // IconButton(
                                //   icon: Icon(Icons.done),
                                //   onPressed: () {
                                //     // Tambahkan aksi untuk tombol delete di sini
                                //   },
                                // ),

                                IconButton(
                                  onPressed: () => _launchWhatsApp(
                                      item['no_telp_pelanggan'],
                                      'Hallo, Saya $username kurir dapur mamak arvin ingin mengantarkan pesanannya, terimakasih'),
                                  icon: Icon(Icons.message_outlined),
                                  color: Colors.blueAccent,
                                ),

                                //selesai
                                IconButton(
                                  icon:
                                      Icon(Icons.check_circle_outline_rounded),
                                  color: Colors.black87,
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text("Konfirmasi"),
                                          content: Text(
                                              "Apakah Anda ingin menyelesaikan pesanan ini ?"),
                                          actions: [
                                            ElevatedButton(
                                              onPressed: () async {
                                                try {
                                                  final response =
                                                      await http.post(
                                                    Uri.parse(BaseURL.done),
                                                    body: {
                                                      "id_pesanan":
                                                          item['id_pesanan'],
                                                    },
                                                  );

                                                  if (response.statusCode ==
                                                      200) {
                                                    _refreshData();
                                                    // Data berhasil dikirim
                                                    // Tambahkan logika untuk menanggapi respon yang berhasil di sini
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
                                ),
                              ],
                            ),
                          ),
                        ),
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
}
