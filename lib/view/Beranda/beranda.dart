import 'dart:async';

import 'package:badges/badges.dart';
import 'package:destask/controller/personil_controller.dart';
import 'package:destask/controller/rekap_point_controller.dart';
import 'package:destask/controller/target_poin_harian_controller.dart';
import 'package:destask/controller/task_controller.dart';
import 'package:destask/controller/user_controller.dart';
import 'package:destask/model/target_poin_harian_model.dart';
import 'package:quickalert/quickalert.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../controller/notifikasi_controller.dart';
import '../../controller/pekerjaan_controller.dart';
import '../../model/pekerjaan_model.dart';
import '../../utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:get/get.dart';

class Beranda extends StatefulWidget {
  const Beranda({Key? key}) : super(key: key);

  @override
  State<Beranda> createState() => _BerandaState();
}

class _BerandaState extends State<Beranda> {
  TargetPoinHarianController targetPoinHarianController =
      TargetPoinHarianController();
  PekerjaanController pekerjaanController = PekerjaanController();
  PersonilController personilController = PersonilController();
  RekapPointController rekapPointController = RekapPointController();
  TaskController taskController = TaskController();
  UserController userController = UserController();
  NotifikasiController notifikasiController = NotifikasiController();
  late List<PekerjaanModel> pekerjaan;
  String nama = '';
  String jumlahPekerjaanSelesai = '';
  String jumlahNotifikasi = '';
  String taskpoint = '';
  String taskselesai = '';

  @override
  void initState() {
    super.initState();
    loadData();
    getDataUser();
  }

  void loadData() async {
    try {
      await getJumlahPekerjaanSelesai();
      await getTaskPoin();
      await getTaskSelesai();
      // await getNotifikasi();
      var data = await getDataPekerjaan();
      setState(() {
        pekerjaan = data;
      });
    } catch (e) {
      print("Error: $e");
      // Handle error appropriately
    }
  }

  getDataUser() async {
    var prefs = await SharedPreferences.getInstance();
    var namauser = prefs.getString('nama');
    setState(() {
      nama = namauser!;
    });
    return nama;
  }

  //getdata pekerjaan
  Future getDataPekerjaan() async {
    var data = await pekerjaanController.getOnProgressUser();
    return data;
  }

  //task poin
  getTaskPoin() async {
    var data = await rekapPointController.getRekapPoint();
    int count = 0;
    for (var i = 0; i < data.length; i++) {
      DateTime taskDate = DateTime.parse(data[i]['tgl_selesai']);
      if (taskDate.month == DateTime.now().month) {
        count += int.parse(data[i]['bobot_point'].toString());
      }
    }
    setState(() {
      taskpoint = count.toString();
    });
    return data;
  }

  getTaskSelesai() async {
    var data = await taskController.getTaskBulanIni();
    int count = 0;
    for (var i = 0; i < data.length; i++) {
      if (data[i].id_status_task.toString() == '3') {
        count += 1;
      }
    }
    setState(() {
      taskselesai = count.toString();
    });
  }

  getJumlahPekerjaanSelesai() async {
    var data = await pekerjaanController.getAllPekerjaanUser();
    int count = 0;
    for (var i = 0; i < data.length; i++) {
      if (data[i].id_status_pekerjaan.toString() == '3' &&
          data[i].waktu_selesai != null) {
        count += 1;
      }
    }
    setState(() {
      jumlahPekerjaanSelesai = count.toString();
    });

    return data;
  }

  //get notifikasi
  // getNotifikasi() async {
  //   var data = await notifikasiController.getNotifikasi();
  //   int count = 0; // Initialize a counter variable
  //   for (var i = 0; i < data.length; i++) {
  //     if (data[i].status_terbaca.toString() == '0') {
  //       count += 1;
  //     }
  //   }
  //   setState(() {
  //     jumlahNotifikasi = count.toString();
  //   });
  //   return data;
  // }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    DateTime currentDate = DateTime.now();
    String dayOfWeek = _getDayOfWeek(currentDate.weekday);
    String formattedDate =
        "${currentDate.day} ${_getMonth(currentDate.month)} ${currentDate.year}";
    return Scaffold(
      appBar: AppBar(
        backgroundColor: GlobalColors.mainColor,
        title: Padding(
          padding: const EdgeInsets.only(top: 10, left: 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hi, $nama",
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
              const Text(
                'Selamat Datang di Destask',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white),
              ),
            ],
          ),
        ),
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.only(top: 10, right: 15),
        //     child: GestureDetector(
        //       onTap: () {
        //         Get.toNamed('/notifikasi');
        //       },
        //       child: Container(
        //         decoration: BoxDecoration(
        //           color: Colors.blue[300],
        //           borderRadius: BorderRadius.circular(10),
        //         ),
        //         padding: const EdgeInsets.all(8.0),
        //         child: badges.Badge(
        //           badgeContent: Text(
        //             jumlahNotifikasi.toString(),
        //             style: const TextStyle(color: Colors.white),
        //           ),
        //           badgeStyle: const BadgeStyle(
        //               badgeColor: Colors.red, // Red circle color
        //               elevation: 4, // No shadow
        //               padding: EdgeInsets.only(
        //                   top: 5, bottom: 5, left: 5, right: 5)),
        //           child: const Icon(
        //             Icons.notifications,
        //             color: Colors.white,
        //           ),
        //         ),
        //       ),
        //     ),
        //   ),
        // ],
      ),
      body: Stack(
        children: [
          // Kotak Biru
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: screenWidth,
              height: screenHeight / 10,
              color: GlobalColors.mainColor,
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$dayOfWeek, ',
                          style: const TextStyle(
                              fontSize: 18, color: Colors.white),
                        ),
                        Text(
                          formattedDate,
                          style: const TextStyle(
                              fontSize: 18, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Kotak Bawah
          Positioned(
            top: screenHeight / 5,
            left: 0,
            child: Container(
              width: screenWidth,
              height: screenHeight * 3 / 4,
              color: Colors.white,
              child: SingleChildScrollView(
                child: FutureBuilder(
                  future: getDataPekerjaan(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 200),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 200),
                        child: Center(child: Text('No data available.')),
                      );
                    } else if (snapshot.hasData) {
                      List<PekerjaanModel> pekerjaan = snapshot.data!;
                      return pekerjaanlist(pekerjaan);
                    } else {
                      return const Center(child: Text('No data available.'));
                    }
                  },
                ),
              ),
            ),
          ),
          // Kotak Tengah
          Positioned(
            top: screenHeight / 17,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.only(left: 15, right: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.lightBlue[300],
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 25),
                child: GridView.builder(
                  itemCount: names.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.1,
                  ),
                  itemBuilder: (context, index) {
                    Widget badgecontent;

                    if (index == 0) {
                      badgecontent = Text(
                        jumlahPekerjaanSelesai,
                        style: const TextStyle(color: Colors.white),
                      );
                    } else if (index == 1) {
                      badgecontent = Text(
                        taskselesai,
                        style: const TextStyle(color: Colors.white),
                      );
                    } else if (index == 2) {
                      badgecontent = Text(
                        taskpoint,
                        style: const TextStyle(color: Colors.white),
                      );
                    } else {
                      badgecontent = const Text(
                        '0',
                        style: TextStyle(color: Colors.white),
                      );
                    }
                    return Column(
                      children: [
                        badges.Badge(
                          badgeContent: badgecontent,
                          badgeStyle: const BadgeStyle(
                            badgeColor: Colors.red, // Red circle color
                            elevation: 0, // No shadow
                            padding: EdgeInsets.all(
                                10), // Padding around the badge content
                          ),
                          child: InkWell(
                            onTap: () {
                              if (index == 0) {
                                Get.toNamed('/pekerjaan_selesai');
                              } else if (index == 1) {
                                Get.toNamed('/task_selesai');
                              } else if (index == 2) {
                                Get.toNamed('/rekap_point');
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: colors[index],
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: nameIcon[index],
                            ),
                          ),
                        ),
                        Text(
                          names[index],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Padding pekerjaanlist(List<PekerjaanModel> pekerjaan) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          const Text(
            "ON PROGRESS",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black, // Choose your desired text color
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Column(
              children: pekerjaan.map((pekerjaanItem) {
                return Card(
                  color: GlobalColors.mainColor,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.toNamed('/task/${pekerjaanItem.id_pekerjaan}');
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(15),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${pekerjaanItem.data_tambahan.persentase_task_selesai}%',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            title: Text(
                              pekerjaanItem.nama_pekerjaan!,
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              "PM: ${pekerjaanItem.data_tambahan.pm[0].nama!}",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      const Divider(),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding:
                                  const EdgeInsets.only(top: 3, bottom: 13),
                              child: GestureDetector(
                                onTap: () {
                                  Get.toNamed(
                                      '/detail_pekerjaan/${pekerjaanItem.id_pekerjaan}');
                                },
                                child: const Center(
                                  child: Text(
                                    'Detail',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(
            height: 100,
          ),
        ],
      ),
    );
  }
}

List<Color> colors = [
  Colors.amber,
  Colors.green,
  Colors.purple,
];

List<String> names = [
  'Pekerjaan\nSelesai',
  'Task Selesai\nBulan Ini',
  'Point Task\n Bulan Ini'
];

List<Icon> nameIcon = const [
  Icon(
    Icons.work,
    size: 30,
    color: Colors.white,
  ),
  Icon(
    Icons.calendar_today,
    size: 30,
    color: Colors.white,
  ),
  Icon(
    Icons.check_circle,
    size: 30,
    color: Colors.white,
  ),
];

String _getDayOfWeek(int day) {
  switch (day) {
    case 1:
      return 'Senin';
    case 2:
      return 'Selasa';
    case 3:
      return 'Rabu';
    case 4:
      return 'Kamis';
    case 5:
      return 'Jumat';
    case 6:
      return 'Sabtu';
    case 7:
      return 'Minggu';
    default:
      return '';
  }
}

String _getMonth(int month) {
  switch (month) {
    case 1:
      return 'Januari';
    case 2:
      return 'Februari';
    case 3:
      return 'Maret';
    case 4:
      return 'April';
    case 5:
      return 'Mei';
    case 6:
      return 'Juni';
    case 7:
      return 'Juli';
    case 8:
      return 'Agustus';
    case 9:
      return 'September';
    case 10:
      return 'Oktober';
    case 11:
      return 'November';
    case 12:
      return 'Desember';
    default:
      return '';
  }
}
