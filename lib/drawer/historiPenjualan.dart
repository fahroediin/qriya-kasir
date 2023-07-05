import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:project_s/pages/home_page.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'editHistoriPenjualan.dart';

class HistoriPenjualanPage extends StatefulWidget {
  const HistoriPenjualanPage({Key? key}) : super(key: key);

  @override
  State<HistoriPenjualanPage> createState() => _HistoriPenjualanPageState();
}

class _HistoriPenjualanPageState extends State<HistoriPenjualanPage> {
  Query dbRef = FirebaseDatabase.instance
      .reference()
      .child('transaksiPenjualan')
      .orderByKey()
      .limitToLast(50);
  List<BluetoothDevice> devices = [];
  BluetoothDevice? selectedDevice;
  BlueThermalPrinter printer = BlueThermalPrinter.instance;
  int itemCount = 0;
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  Query? searchRef;

  Widget buildListItem(DataSnapshot snapshot) {
    Map? transaksi = snapshot.value as Map?;
    String idPenjualan = transaksi?['idPenjualan'] ?? '';
    String dateTime = transaksi?['dateTime'] ?? '';
    String namaPembeli = transaksi?['namaPembeli'] ?? '';
    List<Map>? items = (transaksi?['items'] as List<dynamic>?)?.cast<Map>();
    int totalBayar = transaksi?['totalHarga'] ?? 0;
    int bayar = transaksi?['bayar'] ?? 0;
    int kembalian = transaksi?['kembalian'] ?? 0;
    int diskon = transaksi?['diskon'] ?? 0;
    int hargaAkhir = totalBayar - (totalBayar * diskon ~/ 100);

    return Card(
      child: Stack(
        children: [
          ListTile(
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
                        int hargaSparepart =
                            item['hargaSparepart'] as int? ?? 0;
                        int jumlahItem = item['jumlahSparepart'] ?? 0;
                        return Padding(
                          padding: EdgeInsets.only(left: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ID Sparepart: $idSparepart'),
                              Text('Nama Sparepart: $namaSparepart'),
                              Text('Harga Sparepart: Rp $hargaSparepart'),
                              Text('Jumlah Item: $jumlahItem'),
                            ],
                          ),
                        );
                      }).toList() ??
                      [],
                ),
                Text('Harga: Rp $totalBayar'),
                Text('Diskon: $diskon%'),
                Text('Harga Akhir: Rp $hargaAkhir'),
                Text('Bayar: Rp $bayar'),
                Text('Kembalian: Rp $kembalian'),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditHistoriPenjualanPage(
                          idPenjualan: '',
                        ),
                      ),
                    );
                  },
                  icon: Icon(Icons.edit),
                ),
                IconButton(
                  onPressed: () {
                    // Tambahkan kode untuk fungsi print di sini
                  },
                  icon: Icon(Icons.print),
                ),
              ],
            ),
          ),
        ],
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
    getDevices();
  }

  void getDevices() async {
    devices = await printer.getBondedDevices();
    setState(() {});
  }

  Future<void> fetchData() async {
    if (searchQuery.isNotEmpty) {
      searchRef = FirebaseDatabase.instance
          .reference()
          .child('transaksiPenjualan')
          .orderByChild('namaPembeli_idPenjualan')
          .startAt(searchQuery.toLowerCase())
          .endAt(searchQuery.toLowerCase() + '\uf8ff');
    } else {
      searchRef = dbRef;
    }

    DataSnapshot snapshot = await searchRef!.get();

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
          'Histori Penjualan',
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Transaksi: $itemCount',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                            fetchData(); // Tambahkan baris ini
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Cari Data Transaksi [Nama Pembeli]',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    IconButton(
                      onPressed: () {
                        searchController.clear();
                        setState(() {
                          searchQuery = '';
                        });
                        fetchData();
                      },
                      icon: Icon(Icons.clear),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: FirebaseAnimatedList(
              query: searchRef ?? dbRef,
              itemBuilder: (BuildContext context, DataSnapshot snapshot,
                  Animation<double> animation, int index) {
                return buildListItem(snapshot);
              },
              defaultChild: buildNoDataWidget(),
            ),
          ),
        ],
      ),
    );
  }
}
