import 'dart:io';
import 'package:destask/controller/pekerjaan_controller.dart';
import 'package:destask/model/pekerjaan_model.dart';

import '../../../controller/kategori_task_controller.dart';
import '../../../controller/task_controller.dart';
import '../../../model/kategori_task_model.dart';
import 'package:quickalert/quickalert.dart';
import '../../../controller/status_task_controller.dart';
import '../../../model/status_task_model.dart';
import '../../../utils/global_colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'my_date_time_picker.dart';

class AddTask extends StatefulWidget {
  const AddTask({super.key});

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  final String idpekerjaan = Get.parameters['idpekerjaan'] ?? '';
  final String idUser = Get.parameters['iduser'] ?? '';
  final TextEditingController _deskripsiTaskController =
      TextEditingController();
  final TextEditingController _tautanTaskController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  StatusTaskController statusTaskController = StatusTaskController();
  KategoriTaskController kategoriTaskController = KategoriTaskController();
  TaskController taskController = TaskController();
  PekerjaanController pekerjaanController = PekerjaanController();

  //file
  PlatformFile? pickedFile;
  File? fileToDisplay;
  String? fileName;
  String filePath = "";
  bool isLoading = false;
  String idStatusTask = "";
  String idKategoriTask = "";
  String namaPekerjaan = "";

  @override
  void initState() {
    super.initState();
    getDataPekerjaan();
    getDataStatusTask();
    getDataKategoriTask();
  }

  getDataPekerjaan() async {
    List<PekerjaanModel> dataPekerjaan =
        await pekerjaanController.getPekerjaanById(idpekerjaan);
    if (dataPekerjaan.isNotEmpty) {
      setState(() {
        namaPekerjaan = dataPekerjaan[0].nama_pekerjaan.toString();
      });
    } else {
      setState(() {
        namaPekerjaan = "Pekerjaan tidak ditemukan";
      });
    }
    print(namaPekerjaan);
    return dataPekerjaan;
  }

  //get status task
  Future<List<StatusTaskModel>> getDataStatusTask() async {
    List<StatusTaskModel> dataStatus =
        await statusTaskController.getAllStatusTask();
    return dataStatus;
  }

  //getkategori task
  Future<List<KategoriTaskModel>> getDataKategoriTask() async {
    List<KategoriTaskModel> dataKategori =
        await kategoriTaskController.getAllKategoriTask();
    return dataKategori;
  }

  //date picker
  DateTime? _selectedDateStart;

  Future<void> _selectDateStart(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateStart ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != _selectedDateStart) {
      setState(() {
        _selectedDateStart = pickedDate;
      });
    }
  }

  @override
  void dispose() {
    _deskripsiTaskController.dispose();
    _tautanTaskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: GlobalColors.mainColor,
        title:
            const Text('Tambahkan Task', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                //nama pekerjaan
                buildLabel('Nama Pekerjaan'),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  child: Text(
                    namaPekerjaan,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                //deskripsi task
                buildLabel('Deskripsi Task *'),
                buildFormField(_deskripsiTaskController, 'Deskripsi Task',
                    TextInputType.multiline),
                const SizedBox(height: 16),

                //tanggal mulai
                buildLabel('Deadline *'),
                MyDateTimePicker(
                  selectedDate: _selectedDateStart,
                  onChanged: (date) {
                    setState(() {
                      _selectedDateStart = date;
                    });
                  },
                  validator: (date) {
                    if (date == null) {
                      return 'Kolom Tanggal Deadline harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                //status task
                buildLabel('Status Task *'),
                FutureBuilder<List<StatusTaskModel>>(
                  future: getDataStatusTask(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Text('Error loading data');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('No data available');
                    } else {
                      List<StatusTaskModel> statusList = snapshot.data!;
                      return DropdownButtonFormField<String>(
                        onChanged: (value) {
                          setState(() {
                            idStatusTask = value!;
                          });
                        },
                        items: statusList.map((status) {
                          return DropdownMenuItem<String>(
                            value: status.id_status_task,
                            child: Text(status.nama_status_task.toString()),
                          );
                        }).toList(),
                        decoration: const InputDecoration(
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 15, vertical: 3),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Kolom Status Task harus diisi';
                          }
                          return null;
                        },
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                //kategori task
                buildLabel('Kategori Task *'),
                FutureBuilder<List<KategoriTaskModel>>(
                  future: getDataKategoriTask(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Text('Error loading data');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('No data available');
                    } else {
                      List<KategoriTaskModel> kategoriList = snapshot.data!;
                      return DropdownButtonFormField<String>(
                        onChanged: (value) {
                          setState(() {
                            idKategoriTask = value!;
                          });
                        },
                        items: kategoriList.map((kategori) {
                          return DropdownMenuItem<String>(
                            value: kategori.id_kategori_task,
                            child: Text(kategori.nama_kategori_task.toString()),
                          );
                        }).toList(),
                        decoration: const InputDecoration(
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 15, vertical: 3),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Kolom Kategori Task harus diisi';
                          }
                          return null;
                        },
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                //tautan task
                buildLabel('Tautan Task *'),
                buildFormField(
                    _tautanTaskController, "Tautan Task", TextInputType.url),
                const SizedBox(height: 16),
                //simpan
                GestureDetector(
                  onTap: () async {
                    setState(() {
                      isLoading = true;
                    });
                    if (_formKey.currentState!.validate()) {
                      bool addTask = await taskController.addTask(
                        idpekerjaan,
                        idStatusTask,
                        idKategoriTask,
                        _selectedDateStart!, //tgl planing
                        _deskripsiTaskController.text,
                        _tautanTaskController.text,
                      );
                      if (addTask) {
                        Navigator.pushReplacementNamed(
                            context, '/task/$idpekerjaan');
                        QuickAlert.show(
                            context: context,
                            title: "Tambah Task Berhasil",
                            type: QuickAlertType.success);
                      } else {
                        QuickAlert.show(
                            context: context,
                            title: "Tambah Task Gagal",
                            type: QuickAlertType.error);
                      }
                      setState(() {
                        isLoading = false;
                      });
                    } else {
                      setState(() {
                        isLoading = false;
                      });
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: GlobalColors.mainColor,
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: const Text(
                      'Simpan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextFormField buildFormField(
      TextEditingController controller, String label, TextInputType type) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 3),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Kolom $label harus diisi';
        }
        return null;
      },
    );
  }

  Widget buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
