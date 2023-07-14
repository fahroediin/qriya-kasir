import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:project_s/pages/home_page.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({Key? key}) : super(key: key);

  Future<void> _launchWhatsApp(BuildContext context) async {
    const phoneNumber = '081568218009';
    final uri = 'whatsapp://send?phone=$phoneNumber&text=';
    final text =
        'Halo, saya mengalami kendala di aplikasi Qriya. Bisa dibantu?';
    final encodedText = Uri.encodeFull(text);
    final url = uri + encodedText;

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tidak dapat membuka WhatsApp'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 219, 42, 15),
        title: Text('Bantuan'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: Duration(milliseconds: 200),
                pageBuilder: (_, __, ___) => HomePage(),
                transitionsBuilder: (_, animation, __, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              ),
            );
          },
        ),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    'Fitur Utama',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 60,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              'assets/trans.png',
                              width: 24,
                              height: 24,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Transaksi Servis',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Digunakan untuk transaksi servis, sebelum masuk ke halaman transaksi servis, pastikan data pelanggan telah didaftarkan pada menu Input Pelanggan di Homepage',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              'assets/selling.png',
                              width: 24,
                              height: 24,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Transaksi Penjualan',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Digunakan untuk transaksi penjualan non servis, terdapat penambahan data sparepart, lalu dapat menambahkan diskon di dalam transaksi, dan juga dapat mencetak kuitansi',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              'assets/receipt.png',
                              width: 24,
                              height: 24,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Cetak Kuitansi',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Dapat mencetak kuitansi pada transaksi penjualan dan servis, lalu dapat mencetak kuitansi pada halaman histori penjualan dan servis, untuk mencetak ulang kuitansi',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              'assets/receipt.png',
                              width: 24,
                              height: 24,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Laporan',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Terdapat laporan servis dan transaksi penjualan, dapat menampilkan total pendapatan dan total penjualan sparepart, dan memiliki ranking untuk memudahkan pemilik dalam menentukan penambahan barang',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              'assets/report.png',
                              width: 24,
                              height: 24,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Stok Barang',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Anda dapat melihat daftar sparepart yang terdaftar dalam sistem pada Homepage, untuk menambah data sparepart, ke Drawer dan pilih Data Sparepart',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 32),
                Center(
                  child: ElevatedButton(
                    onPressed: () => _launchWhatsApp(context),
                    child: Text('Hubungi Kami'),
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromARGB(255, 219, 42, 15),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
