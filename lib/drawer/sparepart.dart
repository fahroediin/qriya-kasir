import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:intl/intl.dart';
import 'package:project_s/pages/home_page.dart';
import 'insert_sparepart.dart'; // Import halaman tambah data sparepart
import 'update_sparepart.dart'; // Import halaman update data sparepart

class SparepartPage extends StatefulWidget {
  const SparepartPage({Key? key}) : super(key: key);

  @override
  State<SparepartPage> createState() => _SparepartPageState();
}

class _SparepartPageState extends State<SparepartPage> {
  Query dbRef = FirebaseDatabase.instance.reference().child('daftarSparepart');
  int itemCount = 0;
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;
  bool hasData = true;

  String formatCurrency(int value) {
    final format = NumberFormat("#,###");
    return format.format(value);
  }

  void searchList(String query) {
    if (query.isNotEmpty) {
      setState(() {
        isSearching = true;
      });
    } else {
      setState(() {
        isSearching = false;
      });
    }

    fetchData(); // Fetch data based on the search query
  }

  Future<void> fetchData() async {
    Query query = dbRef;
    if (isSearching) {
      String searchText = searchController.text.trim();
      // Perform a compound query using 'idServis' OR 'nopol'
      query = dbRef.orderByChild('namaSparepart').equalTo(searchText);
      DataSnapshot snapshotBynamaSparepart = await query.get();
      DataSnapshot snapshot = await query.get();
      if (!snapshotBynamaSparepart.exists) {
        query = dbRef.orderByChild('specSparepart').equalTo(searchText);
        DataSnapshot snapshotByspec = await query.get();

        if (snapshotByspec.exists) {
          setState(() {
            itemCount = snapshotByspec.children.length;
            hasData = true; // Set the flag to true since data is found
          });
        } else {
          setState(() {
            itemCount =
                0; // Reset the itemCount since there are no matching items
            hasData = false; // Set the flag to false since no data is found
          });
        }
      } else {
        setState(() {
          itemCount = snapshotBynamaSparepart.children.length;
          hasData = true; // Set the flag to true since data is found
        });
      }
    } else {
      // When not searching, get the last 50 items
      Query query = dbRef.orderByKey().limitToLast(50);
      DataSnapshot snapshot = await query.get();

      if (snapshot.exists) {
        setState(() {
          itemCount = snapshot.children.length;
          hasData = true; // Set the flag to true since data is found
        });
      } else {
        setState(() {
          itemCount =
              0; // Reset the itemCount since there are no matching items
          hasData = false; // Set the flag to false since no data is found
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Widget listItem({required Map sparepart}) {
    Color stockColor = Colors.black; // Warna default
    String stockText =
        'Stok: ${sparepart['stokSparepart']}'; // Teks stok default

    if (sparepart['stokSparepart'] <= 5) {
      stockColor = Colors.red; // Warna merah jika stok <= 5
      stockText =
          'Stok: ${sparepart['stokSparepart']}  !! Harap restock !!'; // Teks stok dengan tambahan "Harap restock"
    }
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      height: 220, // Atur tinggi sesuai kebutuhan Anda
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 232, 192, 145),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ID: ${sparepart['idSparepart']}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Nama: ${sparepart['namaSparepart']}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Spesifikasi: ${sparepart['specSparepart']}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Merk: ${sparepart['merkSparepart']}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Harga: Rp ' + formatCurrency(sparepart['hargaSparepart']),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 4),
          Text(
            stockText,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: stockColor,
            ),
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  // Implementasi navigasi ke halaman UpdateRecord dengan membawa data sparepart
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          UpdateRecord(sparepartKey: sparepart['key']),
                    ),
                  );
                },
                child: Icon(
                  Icons.edit,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Konfirmasi'),
                        content: const Text('Hapus data sparepart?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Tutup dialog
                            },
                            child: const Text('No'),
                          ),
                          TextButton(
                            onPressed: () {
                              // Hapus data
                              FirebaseDatabase.instance
                                  .reference()
                                  .child('daftarSparepart')
                                  .child(sparepart['key'])
                                  .remove();
                              Navigator.of(context).pop(); // Tutup dialog
                            },
                            child: const Text('Yes'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Icon(
                  Icons.delete,
                  color: Colors.red[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _floatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: Duration(milliseconds: 500),
            pageBuilder: (_, __, ___) => InputSparepartPage(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
      },
      child: Icon(Icons.add),
      backgroundColor: Color.fromARGB(255, 219, 42, 15),
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
                transitionDuration: Duration(milliseconds: 200),
                pageBuilder: (_, __, ___) => HomePage(),
                transitionsBuilder: (_, animation, __, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              ),
            );
          },
        ),
        title: Text(
          'Data Sparepart',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 219, 42, 15),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Total Sparepart : $itemCount',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: searchController,
              onChanged: (value) {
                searchList(value);
              },
              textCapitalization: TextCapitalization
                  .words, // Ini akan mengkapitalkan setiap kata pertama di awal kalimat.
              decoration: InputDecoration(
                labelText: 'Cari Nama atau Spesifikasi',
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
            SizedBox(height: 10),
            Expanded(
              child: hasData
                  ? FirebaseAnimatedList(
                      query: dbRef,
                      itemBuilder: (BuildContext context, DataSnapshot snapshot,
                          Animation<double> animation, int index) {
                        Map sparepart = snapshot.value as Map;
                        sparepart['key'] = snapshot.key;

                        if (!isSearching ||
                            (sparepart['namaSparepart'].toLowerCase().contains(
                                    searchController.text.toLowerCase()) ||
                                sparepart['specSparepart']
                                    .toLowerCase()
                                    .contains(
                                        searchController.text.toLowerCase()))) {
                          return Column(
                            children: [
                              listItem(sparepart: sparepart),
                              SizedBox(height: 8),
                              Divider(color: Colors.grey[400]),
                            ],
                          );
                        } else {
                          return SizedBox();
                        }
                      },
                    )
                  : buildNoDataWidget(),
            ),
          ],
        ),
      ),
      floatingActionButton: _floatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
      ),
    );
  }
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
