import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pdfWidgets;
import 'package:open_file/open_file.dart';

class ReceiptTransactionPage extends StatefulWidget {
  @override
  _ReceiptTransactionPageState createState() => _ReceiptTransactionPageState();
}

class _ReceiptTransactionPageState extends State<ReceiptTransactionPage> {
  late Future<Map<String, dynamic>> _lastTransactionFuture;

  @override
  void initState() {
    super.initState();
    _lastTransactionFuture = fetchLastTransaction();
  }

  Future<Map<String, dynamic>> fetchLastTransaction() async {
    final DatabaseReference databaseRef =
        // ignore: deprecated_member_use
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
    final pdf = pdfWidgets.Document();

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
                  data: (lastTransactionData['items'] ?? [])
                      .map<List<dynamic>>((item) {
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
    final output = await getApplicationDocumentsDirectory();
    final file = File("${output.path}/transaction_receipt.pdf");
    await file.writeAsBytes(await pdf.save());

    // Open the saved PDF file
    OpenFile.open(file.path);

    // Show a SnackBar to inform the user that the PDF has been saved.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Receipt Transaction Has Been Saved'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
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
                                    .map<TableRow>((item) => TableRow(
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
                                        ))
                                    .toList(),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Divider(
                              color: Colors.grey,
                              thickness: 1.5,
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Jumlah Item',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  '${lastTransactionData['jumlahItem']}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Subtotal Sparepart',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  'Rp ${formatCurrency(lastTransactionData['totalHarga'])}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Diskon',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  '${lastTransactionData['diskon']}%',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Diskon',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  'Rp ${formatCurrency(lastTransactionData['totalDiskon'])}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            Divider(
                              color: Colors.grey,
                              thickness: 1.5,
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  'Rp ${formatCurrency(lastTransactionData['hargaAkhir'])}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Bayar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  'Rp ${formatCurrency(lastTransactionData['bayar'])}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Kembalian',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  'Rp ${formatCurrency(lastTransactionData['kembalian'])}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
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
