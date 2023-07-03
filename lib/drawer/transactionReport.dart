import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class TransactionReportPage extends StatefulWidget {
  @override
  _TransactionReportPageState createState() => _TransactionReportPageState();
}

class _TransactionReportPageState extends State<TransactionReportPage> {
  DateTime selectedDate = DateTime.now();
  Query dbRefPenjualan =
      FirebaseDatabase.instance.reference().child('transaksiPenjualan');
  int countdDataPenjualan = 0;
  int jumlahTransaksi = 0; // Menyimpan jumlah transaksi
  int jumlahItemTerjual = 0; // Menyimpan jumlah item terjual

  Future<void> fetchDataPenjualan() async {
    DateTime currentDate = DateTime.now();
    String formattedDate = DateFormat('dd/MM/yyyy').format(currentDate);

    DataSnapshot snapshot = await dbRefPenjualan
        .orderByChild('dateTime')
        .startAt(formattedDate)
        .endAt('$formattedDate\u{f8ff}')
        .get();

    if (mounted) {
      if (snapshot.exists) {
        setState(() {
          countdDataPenjualan = snapshot.children.length;
          jumlahTransaksi =
              countdDataPenjualan; // Set jumlah transaksi sesuai dengan jumlah data penjualan
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting(
        'id_ID', null); // Inisialisasi locale bahasa Indonesia
    fetchDataPenjualan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Laporan Transaksi'),
      ),
      body: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Laporan Bulan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 10),
                      GestureDetector(
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2025),
                          );

                          if (pickedDate != null) {
                            setState(() {
                              selectedDate = pickedDate;
                            });
                            fetchDataPenjualan();
                          }
                        },
                        child: Icon(Icons.calendar_today),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Text('Bulan:'),
                      SizedBox(width: 10),
                      Text(
                        DateFormat('MMMM yyyy', 'id_ID').format(
                            selectedDate), // Gunakan locale bahasa Indonesia
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text('Jumlah Transaksi:'),
                      SizedBox(width: 10),
                      Text(
                        jumlahTransaksi.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text('Jumlah Item Terjual:'),
                      SizedBox(width: 10),
                      Text(
                        jumlahItemTerjual.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
