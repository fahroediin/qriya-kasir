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
  DatabaseReference reference =
      FirebaseDatabase.instance.ref().child('mekanik');

  TextEditingController searchController = TextEditingController();
  late List<Map> filteredList;
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    filteredList = [];
  }

  Widget listItem({required Map mekanik}) {
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
                              reference.child(mekanik['key']).remove();
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
      setState(() {
        isSearching = true;
        filteredList = filteredList
            .where((mekanik) => mekanik['namaMekanik']
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      });
    }
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
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                controller: searchController,
                onChanged: searchList,
                decoration: InputDecoration(
                  labelText: 'Cari Mekanik [ID/Nama]',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
            Expanded(
              child: isSearching
                  ? SingleChildScrollView(
                      child: Column(
                        children: filteredList.map((mekanik) {
                          return Column(
                            children: [
                              listItem(mekanik: mekanik),
                              SizedBox(height: 8),
                              Divider(color: Colors.grey[400]),
                            ],
                          );
                        }).toList(),
                      ),
                    )
                  : FirebaseAnimatedList(
                      query: dbRef,
                      itemBuilder: (BuildContext context, DataSnapshot snapshot,
                          Animation<double> animation, int index) {
                        Map mekanik = snapshot.value as Map;
                        mekanik['key'] = snapshot.key;

                        return Column(
                          children: [
                            listItem(mekanik: mekanik),
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
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 25),
        child: FloatingActionButton(
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
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
