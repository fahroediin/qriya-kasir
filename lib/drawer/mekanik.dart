import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_s/pages/home_page.dart';
import 'insert_data_mekanik.dart'; // Import halaman tambah data mekanik
import 'update_data_mekanik.dart'; // Import halaman update data mekanik

class MekanikPage extends StatefulWidget {
  const MekanikPage({Key? key}) : super(key: key);

  @override
  State<MekanikPage> createState() => _MekanikPageState();
}

class _MekanikPageState extends State<MekanikPage> {
  Query dbRef = FirebaseDatabase.instance.ref().child('mekanik');

  int itemCount = 0;
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;
  bool hasData = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    Query query = dbRef;

    if (isSearching) {
      query = dbRef.orderByChild('namaMekanik').equalTo(searchController.text);
    }

    DataSnapshot snapshot = await query.get();

    if (snapshot.exists) {
      setState(() {
        itemCount = snapshot.children.length;
        hasData = true;
      });
    } else {
      setState(() {
        itemCount = 0;
        hasData = false;
      });
    }
  }

  void searchList(String query) {
    setState(() {
      isSearching = query.isNotEmpty;
    });
    fetchData();
  }

  Widget _floatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: Duration(milliseconds: 200),
            pageBuilder: (_, __, ___) => AddMekanikPage(),
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
          'Data Mekanik',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 219, 42, 15),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Total Mekanik: $itemCount',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) {
                        searchList(value);
                      },
                      decoration: InputDecoration(
                        labelText: 'Cari Mekanik',
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
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
            Expanded(
                child: hasData
                    ? FirebaseAnimatedList(
                        query: dbRef,
                        itemBuilder: (BuildContext context,
                            DataSnapshot snapshot,
                            Animation<double> animation,
                            int index) {
                          Map mekanik = snapshot.value as Map;
                          mekanik['key'] = snapshot.key;

                          if (isSearching &&
                              !mekanik['namaMekanik'].toLowerCase().contains(
                                  searchController.text.toLowerCase())) {
                            return SizedBox(); // Skip this item if it doesn't match the search query
                          }

                          return Column(
                            children: [
                              listItem(mekanik: mekanik, snapshot: snapshot),
                              SizedBox(height: 8),
                              Divider(color: Colors.grey[400]),
                            ],
                          );
                        },
                      )
                    : buildNoDataWidget()),
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

  Widget listItem({required Map mekanik, required DataSnapshot snapshot}) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      height: 160,
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
            'ID                 : ${mekanik['key']}',
            style: GoogleFonts.lato(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Nama            : ${mekanik['namaMekanik']}',
            style: GoogleFonts.lato(
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Alamat         : ${mekanik['alamat']}',
            style: GoogleFonts.lato(
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Nomor HP : ${mekanik['noHp']}',
            style: GoogleFonts.lato(
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
                  // Implementasi navigasi ke halaman UpdateRecord dengan membawa data mekanik
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UpdateRecord(mekanikKey: mekanik['key']),
                    ),
                  );
                },
                child: Icon(
                  Icons.edit,
                  color: Theme.of(context).primaryColorDark,
                ),
              ),
              SizedBox(width: 15),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Konfirmasi'),
                        content: Text('Hapus data mekanik?'),
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
                              FirebaseDatabase.instance
                                  .reference()
                                  .child('mekanik')
                                  .child(mekanik['key'])
                                  .remove();
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
