import 'package:flutter/material.dart';
import 'package:project_s/pages/home_page.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({Key? key}) : super(key: key);

  @override
  _LaporanPageState createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  late String _searchQuery;
  late String _searchCategory;

  @override
  void initState() {
    super.initState();
    _searchQuery = '';
    _searchCategory = 'servis';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 219, 42, 15),
        title: Text('Laporan'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
            icon: Icon(Icons.home),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: _searchCategory,
                  onChanged: (String? newValue) {
                    setState(() {
                      _searchCategory = newValue!;
                    });
                  },
                  items: <String>['servis', 'penjualan']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Cari',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text('Data $index'),
                    subtitle: Text(_searchCategory == 'servis'
                        ? 'Detail data servis'
                        : 'Detail data penjualan'),
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
