import 'package:destask/utils/constant_api.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/quickalert.dart';
import '../../../controller/task_controller.dart';
import '../../../utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DetailVerifikasi extends StatefulWidget {
  const DetailVerifikasi({Key? key}) : super(key: key);

  @override
  State<DetailVerifikasi> createState() => _DetailVerifikasiState();
}

class _DetailVerifikasiState extends State<DetailVerifikasi> {
  var url = '$baseURL/assets/bukti_task/';
  final String idtask = Get.parameters['idtask'] ?? '';
  TaskController taskController = TaskController();
  TextEditingController tglPlaningController = TextEditingController();

  //kolom task
  String idTask = '';
  String idPekerjaan = '';
  String idUser = '';
  String idStatusTask = '';
  String idKategoriTask = '';
  DateTime tglPlaning = DateTime.now();
  String tglSelesai = '';
  String tglVerifikasiDiterima = '';
  String statusVerifikasi = '';
  String persentaseSelesai = '';
  String deskripsiTask = '';
  String alasanVerifikasi = '';
  String buktiSelesai = '';
  String tautanTask = '';

  //bantuan
  String namaUserTask = '';
  String namaPekerjaan = '';
  String namaStatusTask = '';
  String namaKategoriTask = '';

  bool isLoading = false;
  String status = '';

  getDataTask() async {
    print(idtask);
    var data = await taskController.getTaskById(idtask);
    setState(() {
      idTask = data[0].id_task ?? '-';
      idPekerjaan = data[0].id_pekerjaan ?? '-';
      idUser = data[0].id_user ?? '-';
      idStatusTask = data[0].id_status_task ?? '-';
      idKategoriTask = data[0].id_kategori_task ?? '-';
      tglPlaning = DateTime.parse(data[0].tgl_planing.toString());
      persentaseSelesai = data[0].persentase_selesai ?? '-';
      deskripsiTask = data[0].deskripsi_task ?? '-';
      buktiSelesai = data[0].bukti_selesai ?? '-';
      tautanTask = data[0].tautan_task ?? '-';
      namaUserTask = data[0].data_tambahan.nama_user;
      namaPekerjaan = data[0].data_tambahan.nama_pekerjaan;
      namaStatusTask = data[0].data_tambahan.nama_status_task;
      namaKategoriTask = data[0].data_tambahan.nama_kategori_task;
    });
    return data;
  }

  @override
  void initState() {
    super.initState();
    getDataTask();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: GlobalColors.mainColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Detail $deskripsiTask",
          style: const TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(7),
                  1: FlexColumnWidth(0.5),
                  2: FlexColumnWidth(10),
                },
                children: [
                  _buildTableRow('ID Task', idTask),
                  _buildTableRow('Pekerjaan', namaPekerjaan),
                  _buildTableRow('User', namaUserTask),
                  _buildTableRow('Deskripsi Task', deskripsiTask),
                  _buildTableRow('Status Task', namaStatusTask),
                  _buildTableRow('Kategori Task', namaKategoriTask),
                  _buildTableRow(
                      'Deadline',
                      DateFormat('dd MMMM yyyy')
                          .format(DateTime.parse(tglPlaning.toString()))),
                  _buildTableRow('Persentase Selesai', '$persentaseSelesai%'),
                  _buildTableRowLink('Tautan Task', tautanTask),
                  _buildBuktiSelesai('Bukti Selesai', buktiSelesai),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        //menampilkan dialog isinya form alasan verifikasi
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            bool isTodayAfterPlaning =
                                DateTime.now().isAfter(tglPlaning) &&
                                    DateTime.now().day != tglPlaning.day;

                            return AlertDialog(
                              title: const Text('Menolak Verifikasi Task Ini?'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Masukkan alasan penolakan verifikasi task'),
                                  TextField(
                                    maxLines: 2,
                                    decoration: const InputDecoration(
                                      hintText: 'Masukkan alasan',
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        alasanVerifikasi = value;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  if (!isTodayAfterPlaning)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            'Berikan dateline baru (opsional)'),
                                        TextField(
                                          controller: tglPlaningController,
                                          decoration: const InputDecoration(
                                            hintText: 'Tanggal Planing',
                                          ),
                                          onTap: () async {
                                            DateTime? date =
                                                await showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime(2000),
                                              lastDate: DateTime(2100),
                                            );
                                            if (date != null) {
                                              tglPlaningController.text =
                                                  DateFormat('dd MMMM yyyy')
                                                      .format(date);
                                              setState(() {
                                                tglPlaning = date;
                                              });
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    setState(() {
                                      isLoading = true;
                                      status = "2";
                                    });
                                    // Tambahkan logika penanganan di sini
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Kirim'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(top: 16.0),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: const Center(
                          child: Text(
                            'Tolak',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  //terima verifikasi
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        //menampilkan dialog yakin menerima verifikasi
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Yakin Verifikasi Task Ini?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    setState(() {
                                      isLoading = true;
                                      status = "3";
                                      alasanVerifikasi = '-';
                                    });
                                    //edit verifikasi task
                                    bool success =
                                        await taskController.editTaskVerikasi(
                                            idTask, alasanVerifikasi, status);

                                    // Jika verifikasi task berhasil, Anda dapat menambahkan logika penanganan berhasil di sini
                                    if (success) {
                                      Get.offAndToNamed('/bottom_nav');
                                      QuickAlert.show(
                                          context: context,
                                          title: "Berhasil Memverifikasi Task",
                                          type: QuickAlertType.success);
                                      setState(() {
                                        isLoading = false;
                                      });
                                    } else {
                                      QuickAlert.show(
                                          context: context,
                                          title: "Gagal Memverifikasi Task",
                                          type: QuickAlertType.error);
                                      setState(() {
                                        isLoading = false;
                                      });
                                    }
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Terima'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(top: 16.0),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: GlobalColors.mainColor,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: const Center(
                          child: Text(
                            'Terima',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  TableRow _buildTableRow(String label, dynamic value) {
    return TableRow(
      children: [
        TableCell(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        TableCell(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: const Text(":"),
          ),
        ),
        TableCell(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(value.toString()),
          ),
        ),
      ],
    );
  }

  TableRow _buildTableRowLink(String label, String link) {
    return TableRow(
      children: [
        TableCell(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        TableCell(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: const Text(":"),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    link.isNotEmpty
                        ? link.length > 30
                            ? '${link.substring(0, 30)}...'
                            : link
                        : "Tidak ada tautan",
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    if (link.isNotEmpty) {
                      Clipboard.setData(ClipboardData(text: link));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tautan berhasil disalin!'),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  TableRow _buildBuktiSelesai(String label, String namafoto) {
    return TableRow(
      children: [
        TableCell(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        TableCell(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: const Text(":"),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                //cek apakah ada bukti selesai
                namafoto == ''
                    ? const Text('Tidak ada bukti selesai')
                    : GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Dialog(
                                child: Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage('$url/$namafoto'),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: Image.network(
                          '$url/$namafoto',
                          width: 100,
                          height: 100,
                        ),
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
