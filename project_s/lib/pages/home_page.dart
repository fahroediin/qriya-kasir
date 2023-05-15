import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_s/drawer/bantuan.dart';
import 'package:project_s/pages/calculator.dart';
import 'package:project_s/drawer/sukuCadang.dart';
import 'package:project_s/pages/login_page.dart';
import 'package:project_s/pages/servis.dart';
import 'package:project_s/pages/sparepart.dart';
import 'package:project_s/drawer/mekanik.dart';
import 'package:project_s/drawer/report.dart';
import 'package:project_s/drawer/about.dart';
import 'package:intl/intl.dart';
import 'package:project_s/pages/transaksi.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
  }

  void _checkCurrentUser() async {
    User? user = await _auth.currentUser;
    setState(() {
      _user = user;
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
      body: Column(children: [
        Image.asset(
          'assets/airamotor.png',
          height: 150,
          width: 400,
        ),
        SizedBox(height: 0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Container(
            height: 150,
            width: 400,
            decoration: BoxDecoration(
              color: Color.fromRGBO(83, 152, 217, 0.9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 5),
                  child: Text(
                    DateFormat.yMMMMEEEEd().format(DateTime.now()),
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
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 5),
                  child: Text(
                    'Servis : 8',
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 5),
                  child: Text(
                    'Penjualan : 2',
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                )
              ],
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Column(children: [
          Container(
            child: Text(
              '- - Action Menu - -',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w300),
            ),
          ),
        ]),

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
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            ServisPage(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
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
                      primary: Color.fromARGB(255, 244, 143, 177)),
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
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            PenjualanPage(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
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
                      primary: Color.fromARGB(255, 244, 143, 177)),
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
                        'PEMBAYARAN',
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
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            SparepartPage(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
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
                  style: ElevatedButton.styleFrom(primary: Colors.pink[200]),
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
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            CalculatorApp(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
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
                    primary: Color.fromARGB(255, 244, 143, 177),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/calculator.png',
                        height: 125,
                        width: 350,
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'KALKULATOR',
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
      ]),
      drawer: Drawer(
        backgroundColor: Color.fromARGB(244, 182, 172, 153),
        child: Column(
          children: [
            Container(
              height: kToolbarHeight + MediaQuery.of(context).padding.top,
              margin: EdgeInsets.only(bottom: 1.0),
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: UserAccountsDrawerHeader(
                accountName: Text('John Doe'),
                accountEmail: Text('john.doe@gmail.com'),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person),
                ),
                margin: EdgeInsets.zero,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 219, 42, 15),
                ),
              ),
            ),
            SizedBox(height: 10),
            ListTile(
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => MekanikPage(),
                  ),
                );
              },
              leading: Image.asset(
                'assets/mekanik.png',
                height: 50,
                width: 50,
              ),
              title: Text(
                'Data Mekanik',
                style: GoogleFonts.robotoSlab(
                  fontSize: 18,
                ),
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => SukuCadangPage(),
                  ),
                );
              },
              leading: Image.asset(
                'assets/sparepart.png',
                height: 50,
                width: 50,
              ),
              title: Text(
                'Data Sparepart',
                style: GoogleFonts.robotoSlab(
                  fontSize: 18,
                ),
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => LaporanPage(),
                  ),
                );
              },
              leading: Image.asset(
                'assets/report.png',
                height: 50,
                width: 50,
              ),
              title: Text(
                'Laporan',
                style: GoogleFonts.robotoSlab(
                  fontSize: 18,
                ),
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => AboutPage(),
                  ),
                );
              },
              leading: Image.asset(
                'assets/about.png',
                height: 50,
                width: 50,
              ),
              title: Text(
                'Tentang Aplikasi',
                style: GoogleFonts.robotoSlab(
                  fontSize: 18,
                ),
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => HelpPage(),
                  ),
                );
              },
              leading: Icon(
                Icons.support_agent,
                color: Colors.black54,
                size: 50.0,
              ),
              title: Text(
                'Bantuan',
                style: GoogleFonts.robotoSlab(
                  fontSize: 18,
                ),
              ),
            ),
            SizedBox(height: 435),
            ListTile(
              onTap: () async {
                // Menampilkan dialog konfirmasi
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

                // Logout jika pengguna mengkonfirmasi
                if (confirmed) {
                  await FirebaseAuth.instance.signOut();
                  SystemNavigator.pop();
                }
              },
              leading: Image.asset(
                'assets/logout.png',
                height: 50,
                width: 50,
              ),
              title: Text(
                'Logout',
                style: GoogleFonts.robotoSlab(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
