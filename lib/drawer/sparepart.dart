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
  DatabaseReference reference =
      FirebaseDatabase.instance.reference().child('daftarSparepart');

  TextEditingController searchController = TextEditingController();
  List<Map> searchResultList = [];
  List<Map> sparepartList = [];
  List<Map> filteredList = [];
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    filteredList = [];
  }

  String formatCurrency(int value) {
    final format = NumberFormat("#,###");
    return format.format(value);
  }

  void searchList(String query) {
    searchResultList.clear();

    if (query.isNotEmpty) {
      List<Map> searchResult = sparepartList
          .where((sparepart) =>
              sparepart['namaSparepart']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              sparepart['specSparepart']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()))
          .toList();

      if (searchResult.isNotEmpty) {
        setState(() {
          isSearching = true;
          searchResultList.addAll(searchResult);
        });
      } else {
        setState(() {
          isSearching = false;
        });
      }
    } else {
      setState(() {
        isSearching = false;
      });
    }
  }

  Widget listItem({required Map sparepart}) {
    Color stockColor = Colors.black; // Warna default

    if (sparepart['stokSparepart'] <= 5) {
      stockColor = Colors.red; // Warna merah jika stok <= 5
    }
    return Container(
      height: 220, // Atur tinggi sesuai kebutuhan Anda
      width: 400, // Atur lebar sesuai kebutuhan Anda
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
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
            'Merk: ${sparepart['merkSparepart']}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Spec: ${sparepart['specSparepart']}',
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
            'Stok: ${sparepart['stokSparepart']}',
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
                              reference.child(sparepart['key']).remove();
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
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: FloatingActionButton(
          onPressed: () {
            // Implementasi navigasi ke halaman InsertDataSparepart
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => InputSparepartPage()),
            );
          },
          child: Icon(Icons.add),
          backgroundColor: Color.fromARGB(255, 219, 42, 15),
        ),
      ),
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
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                controller: searchController,
                onChanged: (query) {
                  setState(() {
                    searchController.text = query;
                    isSearching = query.isNotEmpty;
                    searchList(query);
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Cari Sparepart [ID/Nama/Spec]',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
            Expanded(
              child: isSearching
                  ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: searchResultList.length,
                      itemBuilder: (BuildContext context, int index) {
                        Map sparepart = searchResultList[index];
                        return Column(
                          children: [
                            listItem(sparepart: sparepart),
                            SizedBox(height: 8),
                            Divider(color: Colors.grey[400]),
                          ],
                        );
                      },
                    )
                  : FirebaseAnimatedList(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      query: dbRef,
                      itemBuilder: (BuildContext context, DataSnapshot snapshot,
                          Animation<double> animation, int index) {
                        Map sparepart = snapshot.value as Map;
                        sparepart['key'] = snapshot.key;

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
      floatingActionButton: _floatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
