import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:project_s/pages/home_page.dart';

class ListSparepartPage extends StatefulWidget {
  const ListSparepartPage({Key? key}) : super(key: key);

  @override
  State<ListSparepartPage> createState() => _ListSparepartPageState();
}

class _ListSparepartPageState extends State<ListSparepartPage> {
  Query dbRef = FirebaseDatabase.instance.reference().child('daftarSparepart');
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

  Widget listItem({required Map sparepart}) {
    return Card(
      child: ListTile(
        title: Text(
          '${sparepart['namaSparepart']} (${sparepart['merkSparepart']} - ${sparepart['specSparepart']})',
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${sparepart['idSparepart']}'),
            Text('Harga: ${sparepart['hargaSparepart']}'),
            Text('Stok: ${sparepart['stokSparepart']}'),
          ],
        ),
      ),
    );
  }

  void searchList(String query) {
    searchResultList.clear();

    if (query.isNotEmpty) {
      List<Map> searchResult = sparepartList
          .where((sparepart) =>
              sparepart['namaSparepart']
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              sparepart['specSparepart']
                  .toLowerCase()
                  .contains(query.toLowerCase()))
          .toList();

      if (searchResult.isNotEmpty) {
        setState(() {
          isSearching = true;
          searchResultList.add(searchResult.first);
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

  Widget buildNoDataWidget() {
    return Center(
      child: Text(
        'Data tidak ada',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
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
                  ? searchResultList.isNotEmpty
                      ? ListView.builder(
                          itemCount: searchResultList.length,
                          itemBuilder: (context, index) {
                            final sparepart = searchResultList[index];
                            return Column(
                              children: [
                                listItem(sparepart: sparepart),
                                SizedBox(height: 8),
                                Divider(color: Colors.grey[400]),
                              ],
                            );
                          },
                        )
                      : buildNoDataWidget()
                  : FirebaseAnimatedList(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      query: dbRef,
                      itemBuilder: (BuildContext context, DataSnapshot snapshot,
                          Animation<double> animation, int index) {
                        Map sparepart = snapshot.value as Map;
                        sparepart['key'] = snapshot.key;
                        sparepartList.add(sparepart); // Tambahkan ini

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
}
