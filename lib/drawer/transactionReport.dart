import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:number_to_words/number_to_words.dart';

class TransactionReportPage extends StatefulWidget {
  @override
  _TransactionReportPageState createState() => _TransactionReportPageState();
}

class _TransactionReportPageState extends State<TransactionReportPage> {
  List<String> monthList = [];
  String selectedMonth = '';

  DatabaseReference dbRefPenjualan =
      FirebaseDatabase.instance.reference().child('transaksiPenjualan');
  int countDataPenjualan = 0;
  int jumlahTransaksi = 0; // Menyimpan jumlah transaksi
  int jumlahItemTerjual = 0; // Menyimpan jumlah item terjual
  int jumlahTotalPendapatan = 0; // Menyimpan jumlah total pendapatan
  int totalDiskon = 0; // Menyimpan total diskon yang diberikan
  int totalPendapatanBersih = 0; // Menyimpan total pendapatan bersih

  List<SparepartRanking> sparepartRankings =
      []; // List untuk menyimpan data SparepartRanking

  Future<void> fetchDataPenjualan() async {
    String formattedMonth = DateFormat('MM/yyyy')
        .format(DateFormat('MMMM yyyy', 'id_ID').parse(selectedMonth));
    DateTime firstDayOfMonth = DateTime(int.parse(formattedMonth.split('/')[1]),
        int.parse(formattedMonth.split('/')[0]), 1);
    DateTime lastDayOfMonth = DateTime(int.parse(formattedMonth.split('/')[1]),
        int.parse(formattedMonth.split('/')[0]) + 1, 0);
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
      if (snapshot.value != null) {
        int totalJumlahItemTerjual = 0;
        int totalHarga = 0;
        int totalDiskonPenjualan = 0;

        Map<dynamic, dynamic>? snapshotValue =
            snapshot.value as Map<dynamic, dynamic>?;
        snapshotValue?.forEach((key, value) {
          if (value is Map<dynamic, dynamic>) {
            int? jumlahItem = int.tryParse(value['jumlahItem'].toString());
            int? hargaAkhir = int.tryParse(value['hargaAkhir'].toString());
            int? diskon = int.tryParse(value['totalDiskon'].toString());

            totalJumlahItemTerjual += jumlahItem ?? 0;
            totalHarga += hargaAkhir ?? 0;
            totalDiskonPenjualan += diskon ?? 0;

            // Menambahkan data SparepartRanking berdasarkan idSparepart
            List<dynamic>? items = value['items'] as List<dynamic>?;
            if (items != null) {
              items.forEach((item) {
                String idSparepart = item['idSparepart'].toString();
                String namaSparepart = item['namaSparepart'].toString();
                String merkSparepart = item['merkSparepart'].toString();

                bool sparepartExist = false;
                for (int i = 0; i < sparepartRankings.length; i++) {
                  if (sparepartRankings[i].idSparepart == idSparepart) {
                    sparepartExist = true;
                    sparepartRankings[i].jumlah += jumlahItem ?? 0;
                    break;
                  }
                }

                if (!sparepartExist) {
                  sparepartRankings.add(SparepartRanking(
                    idSparepart: idSparepart,
                    namaSparepart: namaSparepart,
                    merkSparepart: merkSparepart,
                    jumlah: jumlahItem ?? 0,
                  ));
                }
              });
            }
          }
        });

        // Urutkan sparepartRankings berdasarkan jumlah secara descending
        sparepartRankings.sort((a, b) => b.jumlah.compareTo(a.jumlah));

        setState(() {
          jumlahTransaksi = snapshot.children.length;
          jumlahItemTerjual = totalJumlahItemTerjual;
          jumlahTotalPendapatan = totalHarga;
          totalDiskon = totalDiskonPenjualan;
          totalPendapatanBersih = totalHarga - totalDiskonPenjualan;
        });
      } else {
        // Jika snapshot tidak ada atau data kosong
        setState(() {
          []; // Hapus data yang ada
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

    // Generate list of months
    DateTime now = DateTime.now();
    for (int i = 0; i < 12; i++) {
      DateTime month = DateTime(now.year, now.month - i, 1);
      String monthName = DateFormat('MMMM yyyy', 'id_ID').format(month);
      monthList.add(monthName);
    }

    if (monthList.isNotEmpty) {
      selectedMonth = monthList[0]; // Set the initial selected month
    }
    fetchDataPenjualan();
  }

  Future<void> savePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          children: [
            pw.Header(
              level: 0,
              child: pw.Text('Laporan Transaksi'),
            ),
            pw.Header(
              level: 1,
              child: pw.Text('Bulan: $selectedMonth'),
            ),
            pw.Paragraph(
              text: 'Jumlah Transaksi: ${jumlahTransaksi.toString()}',
            ),
            pw.Paragraph(
              text: 'Jumlah Item Terjual: ${jumlahItemTerjual.toString()}',
            ),
            pw.Paragraph(
              text:
                  'Jumlah Total Pendapatan: Rp ${formatCurrency(jumlahTotalPendapatan)}',
            ),
            pw.Paragraph(
              text: 'Total Diskon: Rp ${formatCurrency(totalDiskon)}',
            ),
            pw.Paragraph(
              text:
                  'Total Pendapatan Bersih: Rp ${formatCurrency(totalPendapatanBersih)}',
            ),
            pw.Header(
              level: 1,
              child: pw.Text('Sparepart Ranking'),
            ),
            if (sparepartRankings.isNotEmpty)
              pw.Table.fromTextArray(
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headers: ['No.', 'ID', 'Nama Sparepart', 'Merk', 'Jumlah'],
                data: List<List<String>>.generate(
                  sparepartRankings.length > 10 ? 10 : sparepartRankings.length,
                  (index) => [
                    (index + 1).toString(),
                    sparepartRankings[index].idSparepart,
                    sparepartRankings[index].namaSparepart,
                    sparepartRankings[index].merkSparepart,
                    sparepartRankings[index].jumlah.toString(),
                  ],
                ),
              )
            else
              pw.Paragraph(
                text: 'Tidak ada data sparepart ranking',
              ),
          ],
        ),
      ),
    );
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/transaction_report.pdf");
    await file.writeAsBytes(await pdf.save());

    // Open the saved PDF file
    OpenFile.open(file.path);

    // Show a SnackBar to inform the user that the PDF has been saved.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('The transaction report PDF is saved successfully.'),
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
        backgroundColor: Color.fromARGB(255, 219, 42, 15),
        title: Text('Laporan Transaksi'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: savePdf,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Laporan Bulan:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 10),
                        DropdownButton<String>(
                          value: selectedMonth,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedMonth = newValue!;
                            });
                            fetchDataPenjualan();
                          },
                          items: monthList.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(fontSize: 18),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Bulan',
                                style: TextStyle(fontSize: 18),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 20),
                                child: Text(
                                  selectedMonth,
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Card(
                child: Column(
                  children: [
                    Text(
                      'Sparepart Ranking',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    if (sparepartRankings.isNotEmpty)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 16.0, // Menambahkan jarak antara kolom
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors
                                    .grey), // Menambahkan border pada tabel
                          ),
                          columns: [
                            DataColumn(
                              label: Container(
                                child: Text(
                                  'No.',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'ID',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Nama',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Merk',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Jumlah',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                          rows: List<DataRow>.generate(
                            sparepartRankings.length > 10
                                ? 10
                                : sparepartRankings.length,
                            (index) => DataRow(
                              cells: [
                                DataCell(
                                  Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 4.0),
                                    decoration: BoxDecoration(),
                                    child: Text((index + 1).toString()),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 4.0),
                                    decoration: BoxDecoration(),
                                    child: Text(
                                        sparepartRankings[index].idSparepart),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 2.0),
                                    decoration: BoxDecoration(),
                                    child: Text(
                                        sparepartRankings[index].namaSparepart),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 4.0),
                                    decoration: BoxDecoration(),
                                    child: Text(
                                        sparepartRankings[index].merkSparepart),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20.0),
                                    child: Text(sparepartRankings[index]
                                        .jumlah
                                        .toString()),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      Text(
                        'Tidak ada data sparepart ranking',
                        style: TextStyle(fontSize: 16),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Card(
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
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Diskon',
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
                    SizedBox(height: 5),
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
      ),
    );
  }
}

class SparepartRanking {
  final String idSparepart;
  final String namaSparepart;
  final String merkSparepart;
  int jumlah;

  SparepartRanking({
    required this.idSparepart,
    required this.namaSparepart,
    required this.merkSparepart,
    required this.jumlah,
  });
}
