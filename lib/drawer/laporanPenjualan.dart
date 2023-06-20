import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:project_s/pages/home_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class LaporanPenjualanPage extends StatefulWidget {
  const LaporanPenjualanPage({Key? key}) : super(key: key);

  @override
  State<LaporanPenjualanPage> createState() => _LaporanPenjualanPageState();
}

class _LaporanPenjualanPageState extends State<LaporanPenjualanPage> {
  Query dbRef =
      FirebaseDatabase.instance.reference().child('transaksiPenjualan');

  int itemCount = 0;

  Widget buildListItem(DataSnapshot snapshot) {
    Map transaksi = snapshot.value as Map;
    String idPenjualan = snapshot.key ?? '';
    String dateTime = transaksi['dateTime'] ?? '';
    String namaPembeli = transaksi['namaPembeli'] ?? '';
    List<Map>? items = (transaksi['items'] as List<dynamic>?)?.cast<Map>();
    double totalBayar = (transaksi['totalHarga'] ?? 0).toDouble();
    double bayar = (transaksi['bayar'] ?? 0).toDouble();
    double kembalian = (transaksi['kembalian'] ?? 0).toDouble();

    return Card(
      child: ListTile(
        title: Text('ID Penjualan: $idPenjualan'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tanggal dan Waktu: $dateTime'),
            Text('Nama Pembeli: $namaPembeli'),
            Text('Items:'),
            Column(
              children: items?.map((item) {
                    String idSparepart = item['idSparepart'] ?? '';
                    String namaSparepart = item['namaSparepart'] ?? '';
                    double hargaSparepart =
                        (item['hargaSparepart'] ?? 0).toDouble();
                    int jumlahItem = item['jumlahSparepart'] ?? 0;
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
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    DataSnapshot snapshot = await dbRef.get();
    if (snapshot.exists) {
      setState(() {
        itemCount = snapshot.children.length;
      });
    }
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
          'Laporan Penjualan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 219, 42, 15),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: Text(
              'Jumlah Data: $itemCount',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            child: Container(
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
          ),
        ],
      ),
    );
  }
}
