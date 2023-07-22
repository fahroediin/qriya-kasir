import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:project_s/pages/home_page.dart';

class ListSparepartPage extends StatefulWidget {
  const ListSparepartPage({Key? key}) : super(key: key);

  @override
  State<ListSparepartPage> createState() => _ListSparepartPageState();
}

class _ListSparepartPageState extends State<ListSparepartPage> {
  Query dbRef = FirebaseDatabase.instance.reference().child('daftarSparepart');
  String _formattedDateTime = '';
  List<Map> sparepartList = [];
  List<Map> filteredSparepartList = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    DataSnapshot snapshot = await dbRef.get();

    if (snapshot.value != null) {
      setState(() {
        sparepartList = List<Map>.from(
            (snapshot.value as Map<dynamic, dynamic>).values.toList());
        filteredSparepartList = sparepartList;
      });
    }
  }

  String formatCurrency(int value) {
    final format = NumberFormat("#,###");
    return format.format(value);
  }

  void searchList(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredSparepartList = sparepartList;
      } else {
        filteredSparepartList = sparepartList.where((sparepart) {
          String namaSparepart =
              sparepart['namaSparepart'].toString().toLowerCase();
          String specSparepart =
              sparepart['specSparepart'].toString().toLowerCase();
          return namaSparepart.contains(query.toLowerCase()) ||
              specSparepart.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Widget buildNoDataWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Text(
            'Data tidak ditemukan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 5), // Jarak antara teks dan teks yang ditambahkan
        Text(
          'Pastikan ejaan dengan benar',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black38,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    HomePage(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  var begin = Offset(1.0, 0.0);
                  var end = Offset.zero;
                  var curve = Curves.ease;

                  var tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));

                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
              ),
            );
          },
        ),
        title: Text(
          'Daftar Sparepart',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 219, 42, 15),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              onChanged: (value) {
                searchList(value);
              },
              decoration: InputDecoration(
                labelText: 'Cari Nama atau Nomor Part',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    searchList('');
                  },
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: filteredSparepartList.isEmpty
                  ? buildNoDataWidget()
                  : ListView.builder(
                      itemCount: filteredSparepartList.length,
                      itemBuilder: (context, index) {
                        Map sparepart = filteredSparepartList[index];
                        return Column(
                          children: [
                            listItem(sparepart: sparepart),
                            SizedBox(height: 8),
                            Divider(color: Colors.grey[400]),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget listItem({required Map sparepart}) {
    int stokSparepart = sparepart['stokSparepart'];
    Color fontColor = stokSparepart <= 5 ? Colors.red : Colors.black;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${sparepart['namaSparepart']} (${sparepart['specSparepart']})',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 5),
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ID: ${sparepart['idSparepart']}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Merk: ${sparepart['merkSparepart']}',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Harga: Rp ${formatCurrency(sparepart['hargaSparepart'])}',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        'Stok: ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${sparepart['stokSparepart']}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: fontColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (stokSparepart <= 5)
                    Text(
                      'Harap Restock',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: fontColor,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
