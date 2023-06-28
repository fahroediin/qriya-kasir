import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pdfWidgets;

class ReceiptTransactionPage extends StatefulWidget {
  @override
  _ReceiptTransactionPageState createState() => _ReceiptTransactionPageState();
}

class _ReceiptTransactionPageState extends State<ReceiptTransactionPage> {
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference();

  late Future<Map<String, dynamic>> _lastTransactionFuture;

  @override
  void initState() {
    super.initState();
    _lastTransactionFuture = fetchLastTransaction();
  }

  Future<Map<String, dynamic>> fetchLastTransaction() async {
    final DatabaseReference databaseRef =
        FirebaseDatabase.instance.reference().child('transaksiPenjualan');

    final DataSnapshot snapshot =
        await databaseRef.orderByKey().limitToLast(1).get();

    final dynamic data = snapshot.value;
    if (data != null && data is Map<dynamic, dynamic>) {
      final String idPenjualan = data.keys.first.toString();
      final Map<dynamic, dynamic> transactionData =
          data[idPenjualan] as Map<dynamic, dynamic>;

      final Map<String, dynamic> convertedTransactionData =
          Map<String, dynamic>.from(transactionData);

      return convertedTransactionData;
    } else {
      return {};
    }
  }

  String formatCurrency(int value) {
    final format = NumberFormat("#,###");
    return format.format(value);
  }

  Future<void> _saveAsPdf(
      BuildContext context, Map<String, dynamic> lastTransactionData) async {
    final pdfWidgets.Document pdf = pdfWidgets.Document();

    pdf.addPage(
      pdfWidgets.Page(
        build: (context) {
          return pdfWidgets.Container(
            padding: pdfWidgets.EdgeInsets.all(16.0),
            child: pdfWidgets.Column(
              crossAxisAlignment: pdfWidgets.CrossAxisAlignment.start,
              children: [
                pdfWidgets.Text(
                  'ID Transaksi: ${lastTransactionData['idPenjualan']}',
                  style: pdfWidgets.TextStyle(
                      fontSize: 18, fontWeight: pdfWidgets.FontWeight.bold),
                ),
                pdfWidgets.SizedBox(height: 10),
                pdfWidgets.Text(
                  'Tanggal dan Waktu: ${lastTransactionData['formattedDateTime']}',
                  style: pdfWidgets.TextStyle(fontSize: 14),
                ),
                pdfWidgets.SizedBox(height: 10),
                pdfWidgets.Text(
                  'Nama Pembeli: ${lastTransactionData['namaPembeli']}',
                  style: pdfWidgets.TextStyle(fontSize: 14),
                ),
                pdfWidgets.SizedBox(height: 20),
                pdfWidgets.Text(
                  'Daftar Barang:',
                  style: pdfWidgets.TextStyle(
                      fontSize: 16, fontWeight: pdfWidgets.FontWeight.bold),
                ),
                pdfWidgets.SizedBox(height: 10),
                pdfWidgets.Table.fromTextArray(
                  headers: [
                    'ID Sparepart',
                    'Nama Sparepart',
                    'Harga',
                    'Jumlah'
                  ],
                  cellAlignment: pdfWidgets.Alignment.centerLeft,
                  headerStyle: pdfWidgets.TextStyle(
                      fontWeight: pdfWidgets.FontWeight.bold),
                  data: (lastTransactionData['items'] ?? []).map((item) {
                    return [
                      item['idSparepart'],
                      item['namaSparepart'],
                      formatCurrency(item['hargaSparepart']),
                      item['jumlahSparepart'].toString(),
                    ].cast<dynamic>().toList();
                  }).toList(),
                ),
                pdfWidgets.SizedBox(height: 20),
                pdfWidgets.Text(
                  'Total Harga: ${formatCurrency(lastTransactionData['totalHarga'])}',
                  style: pdfWidgets.TextStyle(
                      fontSize: 16, fontWeight: pdfWidgets.FontWeight.bold),
                ),
                pdfWidgets.Text(
                  'Diskon: ${lastTransactionData['diskon']}',
                  style: pdfWidgets.TextStyle(
                      fontSize: 16, fontWeight: pdfWidgets.FontWeight.bold),
                ),
                pdfWidgets.Text(
                  'Harga Akhir: ${formatCurrency(lastTransactionData['hargaAkhir'])}',
                  style: pdfWidgets.TextStyle(
                      fontSize: 16, fontWeight: pdfWidgets.FontWeight.bold),
                ),
              ],
            ),
          );
        },
      ),
    );

    // Get the document directory path
    final Directory? directory = await getApplicationSupportDirectory();
    if (directory != null) {
      final String path =
          '${directory.path}/receipt_${lastTransactionData['idPenjualan']}.pdf';
      final File file = File(path);
      await file.writeAsBytes(await pdf.save());

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('PDF Saved'),
            content: const Text('The PDF file has been saved successfully.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Failed to get the document directory.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
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
                future: _lastTransactionFuture,
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
                                        'Kode',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    TableCell(
                                      child: Text(
                                        'Nama',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    TableCell(
                                      child: Text(
                                        'Harga',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    TableCell(
                                      child: Text(
                                        'Jumlah',
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
                                                  .padLeft(7),
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
                              'Harga: ${formatCurrency(lastTransactionData['totalHarga'])} (*disc ${lastTransactionData['diskon']}%)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Total: ${formatCurrency(lastTransactionData['hargaAkhir'])}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Bayar: ${formatCurrency(lastTransactionData['bayar'])}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Kembalian: ${formatCurrency(lastTransactionData['kembalian'])}',
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
        future: _lastTransactionFuture,
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
