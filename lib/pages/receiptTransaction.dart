import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pdfWidgets;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';

class ReceiptTransactionPage extends StatelessWidget {
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference();

  Future<Map<String, dynamic>> _fetchLastTransactionData() async {
    final DatabaseEvent event = await _databaseReference
        .child('transaksiPenjualan')
        .orderByKey()
        .limitToLast(1)
        .once();

    if (event.snapshot.exists) {
      final snapshots = event.snapshot;
      final data = snapshots.value as Map<String, dynamic>;
      return data;
    } else {
      return {};
    }
  }

  Future<void> _saveAsPdf(BuildContext context) async {
    // Fetch last transaction data
    Map<String, dynamic> lastTransactionData =
        await _fetchLastTransactionData();

    final pdfWidgets.Document pdf = pdfWidgets.Document();

    pdf.addPage(
      pdfWidgets.Page(
        build: (context) {
          return pdfWidgets.Column(
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
                headers: ['ID Sparepart', 'Nama Sparepart', 'Harga', 'Jumlah'],
                cellAlignment: pdfWidgets.Alignment.centerLeft,
                headerStyle: pdfWidgets.TextStyle(
                    fontWeight: pdfWidgets.FontWeight.bold),
                data: (lastTransactionData['items'] ?? []).map((item) {
                  return [
                    item['idSparepart'],
                    item['namaSparepart'],
                    item['hargaSparepart'].toString(),
                    item['jumlahSparepart'].toString(),
                  ];
                }).toList(),
              ),
              pdfWidgets.SizedBox(height: 20),
              pdfWidgets.Text(
                'Total Harga: ${lastTransactionData['totalHarga']}',
                style: pdfWidgets.TextStyle(
                    fontSize: 16, fontWeight: pdfWidgets.FontWeight.bold),
              ),
              pdfWidgets.Text(
                'Bayar: ${lastTransactionData['bayar']}',
                style: pdfWidgets.TextStyle(
                    fontSize: 16, fontWeight: pdfWidgets.FontWeight.bold),
              ),
              pdfWidgets.Text(
                'Kembalian: ${lastTransactionData['kembalian']}',
                style: pdfWidgets.TextStyle(
                    fontSize: 16, fontWeight: pdfWidgets.FontWeight.bold),
              ),
            ],
          );
        },
      ),
    );

    // Save the PDF file.
    final String dir = (await getApplicationDocumentsDirectory()).path;
    final String path =
        '$dir/receipt_${lastTransactionData['idPenjualan']}.pdf';
    final File file = File(path);
    await file.writeAsBytes(await pdf.save());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('PDF Saved'),
          content: const Text('The receipt has been saved as PDF.'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<Map<String, dynamic>>(
                future: _fetchLastTransactionData(),
                builder: (BuildContext context,
                    AsyncSnapshot<Map<String, dynamic>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasData) {
                    Map<String, dynamic> lastTransactionData = snapshot.data!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ID Transaksi: ${lastTransactionData['idPenjualan']}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Tanggal dan Waktu: ${lastTransactionData['formattedDateTime']}',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Nama Pembeli: ${lastTransactionData['namaPembeli']}',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Daftar Barang:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Table(
                          columnWidths: {
                            0: FlexColumnWidth(2),
                            1: FlexColumnWidth(3),
                            2: FlexColumnWidth(1),
                            3: FlexColumnWidth(1),
                          },
                          children: [
                            TableRow(
                              children: [
                                TableCell(
                                  child: Text(
                                    'ID Sparepart',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                TableCell(
                                  child: Text(
                                    'Nama Sparepart',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                TableCell(
                                  child: Text(
                                    'Harga',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                TableCell(
                                  child: Text(
                                    'Jumlah',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            ...(lastTransactionData['items'] as List<dynamic>)
                                .map((item) {
                              return TableRow(
                                children: [
                                  TableCell(
                                    child: Text(item['idSparepart']),
                                  ),
                                  TableCell(
                                    child: Text(item['namaSparepart']),
                                  ),
                                  TableCell(
                                    child:
                                        Text(item['hargaSparepart'].toString()),
                                  ),
                                  TableCell(
                                    child: Text(
                                        item['jumlahSparepart'].toString()),
                                  ),
                                ],
                              );
                            }).toList(),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Total Harga: ${lastTransactionData['totalHarga']}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Bayar: ${lastTransactionData['bayar']}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Kembalian: ${lastTransactionData['kembalian']}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => _saveAsPdf(context),
                          child: Text('Save as PDF'),
                        ),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return Text('No data available');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
