import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
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
  late List<Map> filteredList;
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    filteredList = [];
  }

  Widget listItem({required Map sparepart}) {
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
            'Harga: ${sparepart['hargaSparepart']}',
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
              fontWeight: FontWeight.w400,
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
              SizedBox(width: 16),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Confirm'),
                        content: Text('Hapus data sparepart?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Tutup dialog
                            },
                            child: Text('No'),
                          ),
                          TextButton(
                            onPressed: () {
                              // Hapus data
                              reference.child(sparepart['key']).remove();
                              Navigator.of(context).pop(); // Tutup dialog
                            },
                            child: Text('Yes'),
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

  void searchList(String query) {
    if (query.isNotEmpty) {
      List<Map> searchResult = filteredList
          .where((sparepart) => sparepart['namaSparepart']
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();

      setState(() {
        isSearching = true;
        filteredList = searchResult;
      });
    } else {
      setState(() {
        isSearching = false;
      });
    }
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
              MaterialPageRoute(builder: (context) => HomePage()),
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
                onChanged: searchList,
                decoration: InputDecoration(
                  labelText: 'Cari Sparepart',
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
                      itemCount: filteredList.length,
                      itemBuilder: (BuildContext context, int index) {
                        Map sparepart = filteredList[index];
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
