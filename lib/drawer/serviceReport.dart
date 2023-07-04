import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class ServiceReportPage extends StatefulWidget {
  @override
  _ServiceReportPageState createState() => _ServiceReportPageState();
}

class _ServiceReportPageState extends State<ServiceReportPage> {
  DateTime selectedDate = DateTime.now();
  Query dbRefServis =
      FirebaseDatabase.instance.reference().child('transaksiServis');
  int countDataServis = 0;
  int jumlahServis = 0; // Menyimpan jumlah servis
  int totalPendapatan = 0; // Menyimpan total pendapatan

  Future<void> fetchDataServis() async {
    DateTime currentDate = DateTime.now();
    String formattedDate = DateFormat('dd/MM/yyyy').format(currentDate);

    DataSnapshot snapshot = await dbRefServis
        .orderByChild('dateTime')
        .startAt(formattedDate)
        .endAt('$formattedDate\u{f8ff}')
        .get();

    if (mounted) {
      if (snapshot.exists) {
        setState(() {
          countDataServis = snapshot.children.length;
          jumlahServis = countDataServis;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting(
        'id_ID', null); // Inisialisasi locale bahasa Indonesia
    fetchDataServis();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 219, 42, 15),
        title: Text('Laporan Servis'),
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
                            fetchDataServis();
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
                          selectedDate,
                        ), // Gunakan locale bahasa Indonesia
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text('Jumlah Servis:'),
                      SizedBox(width: 10),
                      Text(
                        jumlahServis.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text('Total Pendapatan:'),
                      SizedBox(width: 10),
                      Text(
                        'Rp ${NumberFormat.decimalPattern('id_ID').format(totalPendapatan)}',
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
