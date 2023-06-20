import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_s/drawer/bantuan.dart';
import 'package:project_s/drawer/pelanggan.dart';
import 'package:project_s/pages/insert_pelanggan.dart';
import 'insert_pelanggan.dart';
import 'package:project_s/drawer/calculator.dart';
import 'package:project_s/drawer/sparepart.dart';
import 'package:project_s/pages/login_page.dart';
import 'package:project_s/pages/servis.dart';
import 'package:project_s/pages/listSparepart.dart';
import 'package:project_s/drawer/mekanik.dart';
import 'package:project_s/drawer/laporanPenjualan.dart';
import 'package:project_s/drawer/about.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:project_s/pages/transaksi.dart';
import 'package:project_s/drawer/laporanServis.dart';
import 'dart:io';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  DatabaseReference _databaseReference = FirebaseDatabase.instance.reference();

  int _dataCount = 0;

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
    initializeDateFormatting(
        'id_ID', null); // Initialize date formatting for Indonesian locale
    getDataCount();
  }

  void _checkCurrentUser() async {
    User? user = await _auth.currentUser;
    setState(() {
      _user = user;
    });
  }

  void getDataCount() {
    _databaseReference.child('transaksiServis').once().then((snapshot) {
      if (snapshot != null) {
        Map<dynamic, dynamic> data = snapshot as Map<dynamic, dynamic>;
        setState(() {
          _dataCount = data.length;
        });
      }
    }).catchError((error) {
      print('Failed to get data count: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 219, 42, 15),
        title: Text(
          'QRIYA',
          style: TextStyle(
            fontSize: 28,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              'assets/airamotor.png',
              height: 170,
              width: 400,
            ),
            SizedBox(height: 0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Container(
                height: 150,
                width: 400,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(254, 143, 143, 1),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(255, 71, 67, 67)
                          .withOpacity(0.5), // Warna bayangan
                      spreadRadius: 2, // Penyebaran bayangan
                      blurRadius: 2, // Ukuran blur bayangan
                      offset: Offset(0, 3), // Posisi bayangan
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      child: Text(
                        DateFormat.yMMMMEEEEd('initializedDateFormatting')
                            .format(DateTime
                                .now()), // Format date with Indonesian locale
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      child: Text(
                        'Transaksi Hari ini : 10',
                        style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.normal,
                            color: Color.fromARGB(255, 63, 63, 62)),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      child: Text(
                        'Servis : $_dataCount',
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.normal,
                            color: Color.fromARGB(255, 63, 63, 62)),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      child: Text(
                        'Penjualan : 10',
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.normal,
                            color: Color.fromARGB(255, 63, 63, 62)),
                      ),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Column(
              children: [
                Container(
                  child: Text(
                    '- - Action Menu - -',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w300),
                  ),
                ),
              ],
            ),

            // Grid button
            SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.all(10.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  shrinkWrap: true,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    ServisPage(),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              var begin = Offset(1.0, 0.0);
                              var end = Offset.zero;
                              var curve = Curves.ease;

                              var tween = Tween(begin: begin, end: end)
                                  .chain(CurveTween(curve: curve));

                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromARGB(255, 237, 211, 210),
                        elevation: 5, // Menambahkan elevasi untuk efek bayangan
                        shadowColor: Colors.grey
                            .withOpacity(1), // Warna bayangan (shadow color)
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/trans.png',
                            height: 125,
                            width: 350,
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'SERVIS',
                            style: TextStyle(
                                fontSize: 23,
                                color: Color.fromARGB(239, 42, 41, 41)),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    TransaksiPenjualanPage(),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              var begin = Offset(1.0, 0.0);
                              var end = Offset.zero;
                              var curve = Curves.ease;

                              var tween = Tween(begin: begin, end: end)
                                  .chain(CurveTween(curve: curve));

                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromARGB(255, 237, 211, 210),
                        elevation: 5, // Menambahkan elevasi untuk efek bayangan
                        shadowColor: Colors.grey
                            .withOpacity(1), // Warna bayangan (shadow color)
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/selling.png',
                            height: 125,
                            width: 350,
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'PENJUALAN',
                            style: TextStyle(
                                fontSize: 23,
                                color: Color.fromARGB(239, 42, 41, 41)),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    ListSparepartPage(),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              var begin = Offset(1.0, 0.0);
                              var end = Offset.zero;
                              var curve = Curves.ease;

                              var tween = Tween(begin: begin, end: end)
                                  .chain(CurveTween(curve: curve));

                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 237, 211, 210),
                        elevation: 5, // Menambahkan elevasi untuk efek bayangan
                        shadowColor: Colors.grey
                            .withOpacity(1), // Warna bayangan (shadow color)
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/listSparepart.png',
                            height: 125,
                            width: 350,
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'SPAREPART',
                            style: TextStyle(
                              fontSize: 23,
                              color: Color.fromARGB(239, 42, 41, 41),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    InputPelangganPage(),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              var begin = Offset(1.0, 0.0);
                              var end = Offset.zero;
                              var curve = Curves.ease;

                              var tween = Tween(begin: begin, end: end)
                                  .chain(CurveTween(curve: curve));

                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromARGB(255, 237, 211, 210),
                        elevation: 5, // Menambahkan elevasi untuk efek bayangan
                        shadowColor: Colors.grey
                            .withOpacity(1), // Warna bayangan (shadow color)
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/client.png',
                            height: 125,
                            width: 300,
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'INPUT',
                            style: TextStyle(
                                fontSize: 23,
                                color: Color.fromARGB(239, 42, 41, 41)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text('Admin'),
              accountEmail: Text(_user?.email ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person),
              ),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 219, 42, 15),
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => MekanikPage(),
                  ),
                );
              },
              leading: Icon(Icons.person),
              title: Text('Data Mekanik'),
            ),
            ListTile(
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => SparepartPage(),
                  ),
                );
              },
              leading: Icon(Icons.storage),
              title: Text('Data Sparepart'),
            ),
            ListTile(
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => Pelanggan(),
                  ),
                );
              },
              leading: Icon(Icons.group),
              title: Text('Data Pelanggan'),
            ),
            ListTile(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Pilih Jenis Laporan'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: Icon(Icons.book),
                            title: Text('Laporan Servis'),
                            onTap: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => LaporanServisPage(),
                                ),
                              );
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.shopping_cart),
                            title: Text('Laporan Penjualan'),
                            onTap: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => LaporanPenjualanPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              leading: Icon(Icons.description),
              title: Text('Laporan'),
            ),

            ListTile(
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => CalculatorApp(),
                  ),
                );
              },
              leading: Icon(Icons.calculate),
              title: Text('Kalkulator'),
            ),
            ListTile(
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => AboutPage(),
                  ),
                );
              },
              leading: Icon(Icons.filter_b_and_w_rounded),
              title: Text('Tentang Aplikasi'),
            ),
            // Add more options here for other drawers
            ListTile(
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => HelpPage(),
                  ),
                );
              },
              leading: Icon(Icons.help),
              title: Text('Bantuan'),
            ),
            ListTile(
              onTap: () async {
                final confirmed = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Logout'),
                    content: Text('Apakah kamu yakin ingin logout?'),
                    actions: [
                      TextButton(
                        child: Text('Tidak'),
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                      ),
                      TextButton(
                        child: Text('Ya'),
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  _auth.signOut();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => LoginPage(
                              showRegisterPage: () {},
                            )),
                    (route) => false,
                  );
                }
              },
              leading: Icon(Icons.logout),
              title: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
