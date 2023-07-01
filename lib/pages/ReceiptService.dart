import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pdfWidgets;
import 'package:blue_thermal_printer/blue_thermal_printer.dart';

class ReceiptServisPage extends StatefulWidget {
  @override
  _ReceiptServisPageState createState() => _ReceiptServisPageState();
}

class _ReceiptServisPageState extends State<ReceiptServisPage> {
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference();

  late Future<Map<String, dynamic>> _lastServisFuture;
  late List<BluetoothDevice> _devices;
  late BluetoothDevice _selectedDevice;
  late BlueThermalPrinter _printer;

  @override
  void initState() {
    super.initState();
    _lastServisFuture = fetchLastServis();
    _printer = BlueThermalPrinter.instance;
  }

  Future<Map<String, dynamic>> fetchLastServis() async {
    final DatabaseReference databaseRef =
        FirebaseDatabase.instance.reference().child('transaksiServis');

    final DataSnapshot snapshot =
        await databaseRef.orderByKey().limitToLast(1).get();

    final dynamic data = snapshot.value;
    if (data != null && data is Map<dynamic, dynamic>) {
      final String idServis = data.keys.first.toString();
      final Map<dynamic, dynamic> servisData =
          data[idServis] as Map<dynamic, dynamic>;

      final Map<String, dynamic> convertedServisData =
          Map<String, dynamic>.from(servisData);

      return convertedServisData;
    } else {
      return {};
    }
  }

  String formatCurrency(int value) {
    final format = NumberFormat("#,###");
    return format.format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt'),
        backgroundColor: Color.fromARGB(255, 219, 42, 15),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<Map<String, dynamic>>(
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    Map<String, dynamic> lastTransactionData = snapshot.data!
                        .cast<String, dynamic>(); // Use cast to enforce type
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ID Transaksi: ${lastTransactionData['idPenjualan']}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Tanggal dan Waktu: ${lastTransactionData['dateTime']}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Nama Pembeli: ${lastTransactionData['namaPembeli']}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'List Item:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Divider(
                              color: Colors.grey,
                              thickness: 1.5,
                            ),
                            const SizedBox(height: 5),
                            Table(
                              columnWidths: {
                                0: FlexColumnWidth(2),
                                1: FlexColumnWidth(2),
                                2: FlexColumnWidth(2),
                                3: FlexColumnWidth(1),
                                4: FlexColumnWidth(2),
                              },
                              children: [
                                TableRow(
                                  children: [
                                    TableCell(
                                      child: Text(
                                        'ID',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    TableCell(
                                      child: Text(
                                        'Name',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    TableCell(
                                      child: Text(
                                        'Price',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    TableCell(
                                      child: Text(
                                        'Qty',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                ...lastTransactionData['items']
                                    .map<TableRow>(
                                      (item) => TableRow(
                                        children: [
                                          TableCell(
                                            child: Text(
                                              item['idSparepart'],
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ),
                                          TableCell(
                                            child: Text(
                                              item['namaSparepart'],
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ),
                                          TableCell(
                                            child: Text(
                                              'Rp' +
                                                  formatCurrency(
                                                      item['hargaSparepart']),
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ),
                                          TableCell(
                                            child: Text(
                                              item['jumlahSparepart']
                                                  .toString()
                                                  .padLeft(3),
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                    .toList(),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Harga: Rp ${formatCurrency(lastTransactionData['totalHarga'])} (*disc ${lastTransactionData['diskon']}%)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Total: Rp ${formatCurrency(lastTransactionData['hargaAkhir'])}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Bayar: Rp ${formatCurrency(lastTransactionData['bayar'])}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Kembalian: Rp ${formatCurrency(lastTransactionData['kembalian'])}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return Text('No transaction found.');
                  }
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FutureBuilder<Map<String, dynamic>>(
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            Map<String, dynamic> lastTransactionData = snapshot.data!
                .cast<String, dynamic>(); // Use cast to enforce type
            return FloatingActionButton(
              onPressed: () {
                _saveAsPdf(context, lastTransactionData);
              },
              child: Icon(Icons.save),
              backgroundColor: Color.fromARGB(255, 219, 42, 15),
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }
}

class _saveAsPdf {
  _saveAsPdf(BuildContext context, Map<String, dynamic> lastTransactionData);
}
