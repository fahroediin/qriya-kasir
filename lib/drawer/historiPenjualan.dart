import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:intl/intl.dart';
import 'package:project_s/pages/home_page.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/services.dart';

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
  BluetoothDevice? selectedDevice;
  BlueThermalPrinter printer = BlueThermalPrinter.instance;
  List<BluetoothDevice> devices = [];
  int itemCount = 0;
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  Query? searchRef;
  String _idPenjualan = '';
  String _tanggalTransaksi = '';
  String _namaPembeli = '';
  List<Map>? _items = [];
  int _totalBayar = 0;
  int _bayar = 0;
  int _kembalian = 0;
  int _diskon = 0;
  int _hargaAkhir = 0;

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
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Hapus Data'),
                          content: Text(
                              'Apakah Anda yakin ingin menghapus data ini?'),
                          actions: [
                            TextButton(
                              child: Text('Batal'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text('Hapus'),
                              onPressed: () {
                                FirebaseDatabase.instance
                                    .reference()
                                    .child('transaksiPenjualan')
                                    .child(snapshot.key!)
                                    .remove();
                                Navigator.of(context).pop();
                                fetchData();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: Icon(Icons.delete),
                ),
                IconButton(
                  onPressed: () {
                    _selectPrinter(idPenjualan, dateTime, namaPembeli, items,
                        totalBayar, bayar, kembalian, diskon, hargaAkhir);
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

  String formatCurrency(int value) {
    final format = NumberFormat("#,###");
    return format.format(value);
  }

  void getDevices() async {
    devices = await printer.getBondedDevices();
    setState(() {});
  }

  void _selectPrinter(
    String idPenjualan,
    String dateTime,
    String namaPembeli,
    List<Map>? items,
    int totalBayar,
    int bayar,
    int kembalian,
    int diskon,
    int hargaAkhir,
  ) async {
    if (devices.isEmpty) {
      return;
    }

    final selectedDevice = await showDialog<BluetoothDevice>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Printer'),
          content: SingleChildScrollView(
            child: ListBody(
              children: devices.map((device) {
                return ListTile(
                  onTap: () {
                    Navigator.of(context).pop(device);
                  },
                  leading: const Icon(Icons.print),
                  title: Text(device.name.toString()),
                );
              }).toList(),
            ),
          ),
        );
      },
    );

    if (selectedDevice != null) {
      setState(() {
        this.selectedDevice = selectedDevice;
        _idPenjualan = idPenjualan;
        _tanggalTransaksi = dateTime;
        _namaPembeli = namaPembeli;
        _items = items;
        _totalBayar = totalBayar;
        _bayar = bayar;
        _kembalian = kembalian;
        _diskon = diskon;
        _hargaAkhir = hargaAkhir;
      });

      printReceipt();
    }
  }

  void printReceipt() {
    if (selectedDevice != null) {
      try {
        printer.connect(selectedDevice!).then((_) {
          printer.paperCut();
          printer.printNewLine();
          printer.printCustom(
            'Aira Motor Padangjaya',
            3,
            1,
          );
          printer.printCustom(
            'Servis & Suku Cadang',
            0,
            1,
          );
          printer.printCustom(
            'Jl. Marta Atmaja RT 003/011',
            0,
            1,
          );
          printer.printCustom(
            'Padangjaya, Majenang ',
            0,
            1,
          );
          printer.printCustom(
            '53257 Cilacap, Jawa Tengah',
            0,
            1,
          );
          printer.printCustom(
            'HP 0818-0280-7674',
            1,
            1,
          );
          printer.printNewLine();
          printer.printCustom('ID Penjualan: $_idPenjualan', 1, 0);
          printer.printCustom('Date/Time: $_tanggalTransaksi', 1, 0);
          printer.printCustom('--------------------------------', 0, 0);
          printer.printCustom('Nama Pembeli: $_namaPembeli', 1, 0);
          printer.printCustom('--------------------------------', 0, 0);
          printer.printCustom('Items               Qty   Price', 0, 0);
          for (var item in _items!) {
            String itemName = item['namaSparepart'];
            int quantity = item['jumlahSparepart'];
            int price = item['hargaSparepart'];

            // Pad the strings to align the columns
            String paddedItemName = itemName.padRight(18);
            String paddedQuantity = quantity.toString().padLeft(4);
            String paddedPrice = price.toString().padLeft(9);

            // Calculate the indentation for quantity and price
            int quantityIndentation = (5 - paddedQuantity.length) ~/ 2;
            int priceIndentation = (16 - paddedPrice.length) ~/ 2;

            // Create the final formatted line
            String formattedLine = '$paddedItemName';
            formattedLine += '${' ' * quantityIndentation}$paddedQuantity';
            formattedLine +=
                '${' ' * priceIndentation}${formatCurrency(price)}';

            printer.printCustom(formattedLine, 1, 0);
          }

          printer.printNewLine();
          printer.printCustom('--------------------------------', 0, 0);
          double totalDiskon = (_totalBayar * _diskon) / 100;

          String harga = 'Rp ${_totalBayar.toStringAsFixed(0)}';
          String diskon = '${_diskon.toStringAsFixed(0)}%';
          String potonganHarga = 'Total Diskon'.padRight(20) +
              'Rp ${formatCurrency(totalDiskon.toInt())}';
          int jumlahItem = 0;

          for (var item in _items!) {
            int quantity = item['jumlahSparepart'];
            jumlahItem += quantity;
          }

          String totalItem = jumlahItem.toString();
          String formattedTotalItem = totalItem.padRight(3);

          String totalItemLabel = 'Total Item';
          String totalItemColumn = totalItemLabel.padRight(15);
          String hargaColumn =
              'Rp ' + formatCurrency(_totalBayar.toInt()).padRight(2);

          printer.printCustom(
              '$totalItemColumn$formattedTotalItem  $hargaColumn', 1, 0);

          printer.printCustom('Diskon'.padRight(20) + diskon, 1, 0);
          printer.printCustom(potonganHarga.padRight(20), 1, 0);
          printer.printCustom('--------------------------------', 0, 0);
          printer.printCustom(
              'Total'.padRight(20) +
                  'Rp ${formatCurrency(_hargaAkhir.toInt())}',
              1,
              0);

          printer.printCustom(
              'Bayar'.padRight(20) + 'Rp ${formatCurrency(_bayar.toInt())}',
              1,
              0);
          printer.printCustom(
              'Kembalian'.padRight(20) +
                  'Rp ${formatCurrency(_kembalian.toInt())}',
              1,
              0);

          printer.printNewLine();
          printer.printCustom('Terima Kasih', 2, 1);
          printer.printCustom('Atas Kunjungan Anda', 1, 1);
          printer.printNewLine();
          printer.paperCut();
          Future.delayed(Duration(seconds: 5), () {
            printer.disconnect().then((_) {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Cetak Kuitansi'),
                    content: Text('Berhasil mencetak kuitansi'),
                    actions: <Widget>[
                      TextButton(
                        child: Text('OK'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            });
          });
        });
      } on PlatformException catch (e) {
        print(e.message);
      }
    }
  }

  Future<void> fetchData() async {
    if (searchQuery.isNotEmpty) {
      searchRef = FirebaseDatabase.instance
          .reference()
          .child('transaksiPenjualan')
          .orderByChild('namaPembeli')
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
