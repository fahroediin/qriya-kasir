import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:project_s/pages/home_page.dart';

class LaporanServisPage extends StatefulWidget {
  const LaporanServisPage({Key? key}) : super(key: key);

  @override
  State<LaporanServisPage> createState() => _LaporanServisPageState();
}

class _LaporanServisPageState extends State<LaporanServisPage> {
  Query dbRef = FirebaseDatabase.instance.reference().child('transaksiServis');

  Widget buildListItem(DataSnapshot snapshot) {
    Map transaksi = snapshot.value as Map;
    String idServis = snapshot.key ?? '';
    String dateTime = transaksi['dateTime'] ?? '';
    String idMekanik = transaksi['idMekanik'] ?? '';
    String namaMekanik = transaksi['namaMekanik'] ?? '';
    String nopol = transaksi['nopol'] ?? '';
    String merkSpm = transaksi['merkSpm'] ?? '';
    String tipeSpm = transaksi['tipeSpm'] ?? '';
    String namaPemilik = transaksi['namaPemilik'] ?? '';
    String kerusakan = transaksi['kerusakan'] ?? '';
    List<Map>? sparepartItems =
        (transaksi['sparepartItems'] as List<dynamic>?)?.cast<Map>();
    double biayaServis = (transaksi['biayaServis'] ?? 0).toDouble();
    double totalBayar = (transaksi['totalBayar'] ?? 0).toDouble();
    double bayar = (transaksi['bayar'] ?? 0).toDouble();
    double kembalian = (transaksi['kembalian'] ?? 0).toDouble();

    return Card(
      child: ListTile(
        title: Text('ID Servis: $idServis'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tanggal dan Waktu: $dateTime'),
            Text('ID Mekanik: $idMekanik'),
            Text('Nama Mekanik: $namaMekanik'),
            Text('Nomor Polisi: $nopol'),
            Text('Merk SPM: $merkSpm'),
            Text('Tipe SPM: $tipeSpm'),
            Text('Nama Pemilik: $namaPemilik'),
            Text('Kerusakan: $kerusakan'),
            Text('Sparepart Items:'),
            Column(
              children: sparepartItems?.map((item) {
                    String idSparepart = item['idSparepart'] ?? '';
                    String namaSparepart = item['namaSparepart'] ?? '';
                    double hargaSparepart =
                        (item['hargaSparepart'] ?? 0).toDouble();
                    int jumlahItem = item['jumlahItem'] ?? 0;
                    return Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ID Sparepart: $idSparepart'),
                          Text('Nama Sparepart: $namaSparepart'),
                          Text('Harga Sparepart: $hargaSparepart'),
                          Text('Jumlah Item: $jumlahItem'),
                        ],
                      ),
                    );
                  }).toList() ??
                  [],
            ),
            Text('Biaya Servis: $biayaServis'),
            Text('Total Bayar: $totalBayar'),
            Text('Bayar: $bayar'),
            Text('Kembalian: $kembalian'),
          ],
        ),
      ),
    );
  }

  Widget buildNoDataWidget() {
    return Center(
      child: Text(
        'Data tidak ada',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    HomePage(),
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
        ),
        title: Text(
          'Laporan Servis',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 219, 42, 15),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: FirebaseAnimatedList(
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          query: dbRef,
          itemBuilder: (BuildContext context, DataSnapshot snapshot,
              Animation<double> animation, int index) {
            if (snapshot.value == null) {
              return buildNoDataWidget();
            } else {
              return Column(
                children: [
                  buildListItem(snapshot),
                  SizedBox(height: 8),
                  Divider(color: Colors.grey[400]),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}