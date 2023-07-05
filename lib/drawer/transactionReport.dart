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
  List<Map<dynamic, dynamic>> rankingSparepart =
      []; // Menyimpan ranking sparepart

  Future<void> fetchDataPenjualan() async {
    String formattedMonth = DateFormat('MM/yyyy').format(selectedDate);
    DateTime firstDayOfMonth =
        DateTime(selectedDate.year, selectedDate.month, 1);
    DateTime lastDayOfMonth =
        DateTime(selectedDate.year, selectedDate.month + 1, 0);
    String formattedFirstDayOfMonth =
        DateFormat('dd/MM/yyyy').format(firstDayOfMonth);
    String formattedLastDayOfMonth =
        DateFormat('dd/MM/yyyy').format(lastDayOfMonth);

    DataSnapshot snapshot = await dbRefPenjualan
        .orderByChild('dateTime')
        .startAt(formattedFirstDayOfMonth)
        .endAt(formattedLastDayOfMonth + '\u{f8ff}')
        .get();

    if (mounted) {
      if (snapshot.exists) {
        int totalJumlahItemTerjual = 0;
        Map<String, int> sparepartCountMap = {};

        Map<dynamic, dynamic> snapshotValue =
            snapshot.value as Map<dynamic, dynamic>;
        snapshotValue.forEach((key, value) {
          if (value is Map<dynamic, dynamic>) {
            String? idSparepart = value['idSparepart'] as String?;
            int? jumlahItem = int.tryParse(value['jumlahItem'].toString());

            if (idSparepart != null && jumlahItem != null) {
              if (sparepartCountMap.containsKey(idSparepart)) {
                sparepartCountMap[idSparepart] =
                    (sparepartCountMap[idSparepart] ?? 0) + jumlahItem;
              } else {
                sparepartCountMap[idSparepart] = jumlahItem;
              }
            }

            totalJumlahItemTerjual += jumlahItem ?? 0;
          }
        });

        List<String> uniqueIdSpareparts = sparepartCountMap.keys.toList();

        rankingSparepart = uniqueIdSpareparts.map((idSparepart) {
          String namaSparepart = ''; // Ganti dengan nama sparepart yang sesuai
          String merkSparepart = ''; // Ganti dengan merk sparepart yang sesuai
          int jumlahItem = sparepartCountMap[idSparepart] ?? 0;

          return {
            'idSparepart': idSparepart,
            'namaSparepart': namaSparepart,
            'merkSparepart': merkSparepart,
            'jumlahItem': jumlahItem,
          };
        }).toList();

        rankingSparepart
            .sort((a, b) => b['jumlahItem'].compareTo(a['jumlahItem']));

        setState(() {
          jumlahTransaksi = snapshot.children.length;
          jumlahItemTerjual = totalJumlahItemTerjual;
        });
      } else {
        // If snapshot does not exist or data is empty
        setState(() {
          rankingSparepart = []; // Clear the existing data
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
        backgroundColor: Color.fromARGB(255, 219, 42, 15),
        title: Text('Laporan Transaksi'),
      ),
      body: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Laporan Bulan:',
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
          Divider(),
          Expanded(
            child: rankingSparepart.isEmpty
                ? Center(
                    child: Text('Data tidak ada'),
                  )
                : ListView.builder(
                    itemCount: rankingSparepart.length > 10
                        ? 10
                        : rankingSparepart.length,
                    itemBuilder: (context, index) {
                      final sparepart = rankingSparepart[index];
                      return ListTile(
                        title: Text(
                          '${sparepart['namaSparepart']} - ${sparepart['merkSparepart']}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                            'Jumlah Item Terjual: ${sparepart['jumlahItem']}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
