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
  int jumlahTotalPendapatan = 0; // Menyimpan jumlah total pendapatan
  int totalDiskon = 0; // Menyimpan total diskon yang diberikan
  int totalPendapatanBersih = 0; // Menyimpan total pendapatan bersih
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
        int totalHarga = 0;
        int totalDiskonPenjualan = 0;

        Map<String, int> sparepartCountMap = {};

        Map<dynamic, dynamic> snapshotValue =
            snapshot.value as Map<dynamic, dynamic>;
        snapshotValue.forEach((key, value) {
          if (value is Map<dynamic, dynamic>) {
            String? idSparepart = value['idSparepart'] as String?;
            int? jumlahItem = int.tryParse(value['jumlahItem'].toString());
            int? hargaAkhir = int.tryParse(value['hargaAkhir'].toString());
            int? diskon = int.tryParse(value['totalDiskon'].toString());

            if (idSparepart != null && jumlahItem != null) {
              if (sparepartCountMap.containsKey(idSparepart)) {
                sparepartCountMap[idSparepart] =
                    (sparepartCountMap[idSparepart] ?? 0) + jumlahItem;
              } else {
                sparepartCountMap[idSparepart] = jumlahItem;
              }
            }

            totalJumlahItemTerjual += jumlahItem ?? 0;
            totalHarga += hargaAkhir ?? 0;
            totalDiskonPenjualan += diskon ?? 0;
          }
        });

        List<Map<String, dynamic>> rankingSparepartList =
            sparepartCountMap.entries.map((entry) {
          String idSparepart = entry.key;
          int jumlahItem = entry.value;
          String namaSparepart = ''; // Ganti dengan nama sparepart yang sesuai
          String merkSparepart = ''; // Ganti dengan merk sparepart yang sesuai

          return {
            'idSparepart': idSparepart,
            'namaSparepart': namaSparepart,
            'merkSparepart': merkSparepart,
            'jumlahItem': jumlahItem,
          };
        }).toList();

        rankingSparepartList
            .sort((a, b) => b['jumlahItem'].compareTo(a['jumlahItem']));

        setState(() {
          jumlahTransaksi = snapshot.children.length;
          jumlahItemTerjual = totalJumlahItemTerjual;
          jumlahTotalPendapatan = totalHarga;
          totalDiskon = totalDiskonPenjualan;
          totalPendapatanBersih = totalHarga - totalDiskonPenjualan;
          rankingSparepart = rankingSparepartList;
        });
      } else {
        // If snapshot does not exist or data is empty
        setState(() {
          rankingSparepart = []; // Clear the existing data
        });
      }
    }
  }

  String formatCurrency(int value) {
    final format = NumberFormat("#,###");
    return format.format(value);
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
          Expanded(
            child: Column(
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
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Bulan',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 20),
                                    child: Text(
                                      DateFormat('MMMM yyyy', 'id_ID')
                                          .format(selectedDate),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Jumlah Transaksi',
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 18),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 20),
                                    child: Text(
                                      jumlahTransaksi.toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Jumlah Item Terjual',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 20),
                                    child: Text(
                                      jumlahItemTerjual.toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
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
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Jumlah Total Pendapatan',
                              style: TextStyle(fontSize: 18),
                            ),
                            Text(
                              'Rp ' + formatCurrency(jumlahTotalPendapatan),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Diskon yang diberikan',
                              style: TextStyle(fontSize: 18),
                            ),
                            Text(
                              'Rp ' + formatCurrency(totalDiskon),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Pendapatan Bersih',
                              style: TextStyle(fontSize: 18),
                            ),
                            Text(
                              'Rp ' + formatCurrency(totalPendapatanBersih),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ],
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
