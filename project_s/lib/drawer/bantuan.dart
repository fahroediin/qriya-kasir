import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:project_s/pages/home_page.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({Key? key}) : super(key: key);

  Future<void> _launchWhatsApp() async {
    const phoneNumber = '081568218009';
    final whatsappUrl = 'https://wa.me/081568218009/?text=';
    final text =
        'Halo, saya mengalami kendala di aplikasi Qriya. Bisa dibantu?';
    final encodedText = Uri.encodeFull(text);
    final url = whatsappUrl + encodedText;
    // ignore: deprecated_member_use
    if (await canLaunch(url)) {
      // ignore: deprecated_member_use
      await launch(url);
    } else {
      throw 'Could not launch $url';
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
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Action Menu Servis',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Menu ini digunakan untuk melakukan transaksi perbaikan kendaraan pelanggan. Anda dapat menambahkan informasi kendaraan pelanggan, memilih jenis layanan perbaikan yang dibutuhkan, memilih mekanik yang akan mengerjakan, dan melihat daftar transaksi servis yang sudah dilakukan.',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Menu Penjualan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Menu ini digunakan untuk melakukan aktifitas penjualan suku cadang non servis. Anda dapat menambahkan produk, menghapus produk, dan melihat daftar produk yang sudah dijual.',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Menu Sparepart',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Menu ini berisi data suku cadang yang sudah tersedia di aplikasi. Anda dapat melihat daftar suku cadang yang sudah diinput ke dalam database aplikasi.',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Menu Kalkulator',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Menu ini adalah fitur tambahan aplikasi yang diberikan oleh developer. Anda dapat menggunakan kalkulator untuk melakukan perhitungan dalam proses penjualan atau servis kendaraan.',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: _launchWhatsApp,
                child: Text('Hubungi Kami'),
                style: ElevatedButton.styleFrom(
                  primary: Color.fromARGB(255, 219, 42, 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
