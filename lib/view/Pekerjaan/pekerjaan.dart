import 'package:destask/controller/pekerjaan_controller.dart';
import 'package:destask/utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Pekerjaan extends StatefulWidget {
  const Pekerjaan({Key? key}) : super(key: key);

  @override
  _PekerjaanState createState() => _PekerjaanState();
}

class _PekerjaanState extends State<Pekerjaan>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TextEditingController searchController = TextEditingController();
  PekerjaanController pekerjaanController = PekerjaanController();

  bool isSearchBarVisible = false;
  late Future<List<dynamic>> futurePekerjaan;

  final List<String> statusId = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
  ];

  final List<String> statusNames = [
    'On Progress',
    'Selesai',
    'Pending',
    'Cancel',
    'Bast',
    'Support'
  ];

  final List<IconData> statusIcon = [
    Icons.work,
    Icons.check_circle,
    Icons.pending,
    Icons.cancel,
    Icons.assignment,
    Icons.support,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    futurePekerjaan = PekerjaanController().getAllPekerjaanUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        iconTheme: IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
        title: isSearchBarVisible
            ? TextField(
                controller: searchController,
                style: TextStyle(color: Colors.white),
                autofocus: true,
                onChanged: (value) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: Colors.white60),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        if (searchController.text.isNotEmpty) {
                          searchController.clear();
                        } else {
                          isSearchBarVisible = false;
                        }
                      });
                    },
                  ),
                ),
              )
            : Text('Pekerjaan', style: TextStyle(color: Colors.white)),
        actions: !isSearchBarVisible
            ? [
                IconButton(
                  icon: Icon(Icons.search),
                  color: Colors.white,
                  onPressed: () {
                    setState(() {
                      isSearchBarVisible = !isSearchBarVisible;
                    });
                  },
                ),
              ]
            : null,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelPadding: EdgeInsets.symmetric(horizontal: 10),
          tabs: [
            for (var i = 0; i < statusNames.length; i++)
              Tab(
                icon: Icon(statusIcon[i]),
                text: statusNames[i],
              ),
          ],
          labelStyle: TextStyle(fontSize: 17),
          unselectedLabelStyle: TextStyle(fontSize: 16),
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.blue[100],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          for (var status in statusId)
            StatusPekerjaan(
              futurePekerjaan: futurePekerjaan,
              status: status,
              searchQuery: searchController.text,
            ),
        ],
      ),
    );
  }
}

class StatusPekerjaan extends StatelessWidget {
  const StatusPekerjaan({
    Key? key,
    required this.futurePekerjaan,
    required this.status,
    required this.searchQuery,
  }) : super(key: key);

  final Future<List<dynamic>> futurePekerjaan;
  final String status;
  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: futurePekerjaan,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No data available.'));
        } else if (snapshot.hasData) {
          final filteredList = snapshot.data!
              .where((pekerjaan) =>
                  pekerjaan['id_status_pekerjaan'] == status &&
                  pekerjaan['nama_pekerjaan']
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase()))
              .toList();

          return PekerjaanList(
            status: status,
            pekerjaan: filteredList,
          );
        } else {
          return Center(child: Text('No data available.'));
        }
      },
    );
  }
}

class PekerjaanList extends StatelessWidget {
  final String status;
  final List<dynamic> pekerjaan;

  PekerjaanList({required this.status, required this.pekerjaan});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: pekerjaan.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(top: 3, left: 5, right: 5),
          child: Card(
            color: GlobalColors.mainColor,
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.work,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              title: Text(
                pekerjaan[index]['nama_pekerjaan'].length > 20
                    ? '${pekerjaan[index]['nama_pekerjaan'].substring(0, 20)}...'
                    : pekerjaan[index]['nama_pekerjaan'],
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                "Persentase Selesai : ${pekerjaan[index]['persentase_selesai']}%",
                style: TextStyle(color: Colors.white),
              ),
              trailing: GestureDetector(
                onTap: () {
                  Get.toNamed(
                      '/detail_pekerjaan/${pekerjaan[index]['id_pekerjaan']}');
                },
                child: Icon(
                  Icons.density_small,
                  color: Colors.white,
                ),
              ),
              onTap: () {
                Get.toNamed('/task/${pekerjaan[index]['id_pekerjaan']}');
              },
            ),
          ),
        );
      },
    );
  }
}
