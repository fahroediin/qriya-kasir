import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pdfWidgets;
import 'package:open_file/open_file.dart';

class ServiceReportPage extends StatefulWidget {
  @override
  _ServiceReportPageState createState() => _ServiceReportPageState();
}

class _ServiceReportPageState extends State<ServiceReportPage> {
  List<String> monthList = [];
  String selectedMonth = '';
  int selectedYear = DateTime.now().year;
  Query dbRefServis =
      FirebaseDatabase.instance.reference().child('transaksiServis');
  int countDataServis = 0;
  int jumlahServis = 0; // Menyimpan jumlah servis
  int totalPendapatan = 0; // Menyimpan total pendapatan
  List<Map<String, dynamic>> pelangganRanking = [];
  Map<String, String> namaPelangganMap = {};
  Map<String, int> jumlahMap = {};
  List<Map<String, dynamic>> merkSpmRanking = [];

  Future<void> fetchDataServis() async {
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
    DataSnapshot snapshot =
        await dbRefServis.orderByChild('bulan').equalTo(selectedMonth).get();

    if (mounted) {
      if (snapshot.exists) {
        int count = (snapshot.value as Map<dynamic, dynamic>).length;
        int totalBiayaServis = 0;
        Map<String, int> nopolCountMap = {};

        (snapshot.value as Map<dynamic, dynamic>).forEach((key, value) {
          totalBiayaServis += (value['biayaServis'] ?? 0) as int;
          String nopol = value['nopol'];
          String namaPelanggan = value['namaPelanggan'];
          int jumlah = value['jumlah'] ?? 0;

          nopolCountMap[nopol] = (nopolCountMap[nopol] ?? 0) + 1;

          namaPelangganMap[nopol] = namaPelanggan;
        });

        List<MapEntry<String, int>> nopolCountList =
            nopolCountMap.entries.toList();
        nopolCountList.sort((a, b) => b.value.compareTo(a.value));
        pelangganRanking = nopolCountList
            .take(10)
            .map((entry) => {
                  'nopol': entry.key,
                  'jumlah': entry.value.toString(),
                  'nama': namaPelangganMap[entry.key] ?? '',
                })
            .toList();
        // Mengambil merk sepeda motor dari transaksi servis
        Map<String, int> merkSpmCountMap = {};
        (snapshot.value as Map<dynamic, dynamic>).forEach((key, value) {
          String merkSpm = value['merkSpm'];
          String tipeSpm = value['tipeSpm'];
          String merkSpmKey = '$merkSpm - $tipeSpm';

          merkSpmCountMap[merkSpmKey] = (merkSpmCountMap[merkSpmKey] ?? 0) + 1;
        });

        List<MapEntry<String, int>> merkSpmCountList =
            merkSpmCountMap.entries.toList();
        merkSpmCountList.sort((a, b) => b.value.compareTo(a.value));
        merkSpmRanking = merkSpmCountList
            .take(10)
            .map((entry) => {
                  'merkSpm': entry.key.split(' - ')[0],
                  'tipeSpm': entry.key.split(' - ')[1],
                  'jumlah': entry.value.toString(),
                })
            .toList();
        setState(() {
          countDataServis = count;
          jumlahServis = countDataServis;
          totalPendapatan = totalBiayaServis;
        });
      }
    }
  }

  Future<List<String>> getDistinctMonths() async {
    DataSnapshot snapshot = await dbRefServis.orderByChild('bulan').get();
    List<String> distinctMonths = [];

    if (snapshot.exists) {
      (snapshot.value as Map<dynamic, dynamic>).forEach((key, value) {
        if (value['bulan'] != null) {
          String month = value['bulan'];
          if (!distinctMonths.contains(month)) {
            distinctMonths.add(month);
          }
        }
      });
    }

    return distinctMonths;
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);

    initializeMonthList().then((_) {
      fetchDataServis();
    });
  }

  Future<void> initializeMonthList() async {
    DataSnapshot snapshot = await dbRefServis.get();
    if (snapshot.value != null) {
      Set<String> uniqueMonths = {};
      Map<dynamic, dynamic>? snapshotValue =
          snapshot.value as Map<dynamic, dynamic>?;
      snapshotValue?.forEach((key, value) {
        if (value is Map<dynamic, dynamic>) {
          String? bulan = value['bulan'].toString();
          if (bulan != null) {
            uniqueMonths.add(bulan);
          }
        }
      });

      setState(() {
        monthList = uniqueMonths.toList();
        monthList.sort((a, b) {
          DateTime aDate = DateFormat('MMMM yyyy', 'id_ID').parse(a);
          DateTime bDate = DateFormat('MMMM yyyy', 'id_ID').parse(b);
          return bDate.compareTo(aDate);
        });

        if (monthList.isNotEmpty) {
          selectedMonth = monthList[0];
        }
      });
    }
  }

  Future<void> savePdf() async {
    final pdf = pdfWidgets.Document();

    pdf.addPage(
      pdfWidgets.Page(
        build: (context) => pdfWidgets.Column(
          children: [
            pdfWidgets.Header(
              level: 0,
              child: pdfWidgets.Text('Laporan Servis'),
            ),
            pdfWidgets.Header(
              level: 1,
              child: pdfWidgets.Text('Bulan: $selectedMonth'),
            ),
            pdfWidgets.Paragraph(
              text: 'Jumlah Servis: ${jumlahServis.toString()}',
            ),
            pdfWidgets.Paragraph(
              text:
                  'Total Pendapatan Servis: Rp ${NumberFormat.decimalPattern('id_ID').format(totalPendapatan)}',
            ),
            pdfWidgets.Header(
              level: 2,
              child: pdfWidgets.Text('Pelanggan Ranking'),
            ),
            pdfWidgets.Table.fromTextArray(
              headers: ['No.', 'Nopol', 'Nama', 'Jumlah'],
              data: pelangganRanking
                  .asMap()
                  .entries
                  .map(
                    (entry) => [
                      (entry.key + 1).toString(),
                      entry.value['nopol'],
                      namaPelangganMap[entry.value['nopol']] ?? '',
                      entry.value['jumlah'],
                    ],
                  )
                  .toList(),
            ),
            pdfWidgets.Header(
              level: 2,
              child: pdfWidgets.Text('Merk Sepeda Motor Ranking'),
            ),
            pdfWidgets.Table.fromTextArray(
              headers: ['No.', 'Merk', 'Tipe', 'Jumlah'],
              data: merkSpmRanking
                  .asMap()
                  .entries
                  .map(
                    (entry) => [
                      (entry.key + 1).toString(),
                      entry.value['merkSpm'],
                      entry.value['tipeSpm'],
                      entry.value['jumlah'],
                    ],
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/service_report.pdf");
    await file.writeAsBytes(await pdf.save());

    // Open the saved PDF file
    OpenFile.open(file.path);

    // Show a SnackBar to inform the user that the PDF has been saved.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Laporan servis dalam bentuk PDF berhasil disimpan.'),
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
        title: Text('Laporan Servis'),
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
            Card(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
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
                        DropdownButton<String>(
                          value: selectedMonth,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedMonth = newValue!;
                              fetchDataServis();
                            });
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
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Bulan:',
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          '$selectedMonth',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Jumlah Servis:',
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          jumlahServis.toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Pendapatan Servis:',
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          'Rp ${NumberFormat.decimalPattern('id_ID').format(totalPendapatan)}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Pelanggan Ranking',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Divider(
              color: Colors.grey,
              thickness: 1.5,
            ),
            DataTable(
              columnSpacing: 30,
              columns: [
                DataColumn(
                  label: Text(
                    'No.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Nopol',
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
                    'Jumlah',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows: pelangganRanking.asMap().entries.map((entry) {
                int index = entry.key + 1;
                Map<String, dynamic> pelanggan = entry.value;
                String nopol = pelanggan['nopol'];
                String nama = namaPelangganMap[nopol] ?? '';
                int jumlah = int.parse(pelanggan['jumlah']);

                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        index.toString(),
                      ),
                    ),
                    DataCell(
                      Text(nopol),
                    ),
                    DataCell(
                      Text(nama),
                    ),
                    DataCell(
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          jumlah.toString(),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
              dividerThickness: 1.5,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Merk Sepeda Motor Ranking',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Divider(
              color: Colors.grey,
              thickness: 1.5,
            ),
            DataTable(
              columnSpacing: 30,
              columns: [
                DataColumn(
                  label: Text(
                    'No.',
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
                    'Tipe',
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
              rows: merkSpmRanking.asMap().entries.map((entry) {
                int index = entry.key + 1;
                Map<String, dynamic> merkSpm = entry.value;
                String merk = merkSpm['merkSpm'];
                String tipe = merkSpm['tipeSpm'];
                int jumlah = int.parse(merkSpm['jumlah']);

                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        index.toString(),
                      ),
                    ),
                    DataCell(
                      Text(merk),
                    ),
                    DataCell(
                      Text(tipe),
                    ),
                    DataCell(
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          jumlah.toString(),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
              dividerThickness: 1.5,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
