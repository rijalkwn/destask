import 'dart:io';

import '../../../controller/kategori_task_controller.dart';
import '../../../controller/task_controller.dart';
import '../../../model/kategori_task_model.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../controller/status_task_controller.dart';
import '../../../model/status_task_model.dart';
import '../../../model/task_model.dart';
import '../../../utils/global_colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'my_date_time_picker.dart';

class EditTask extends StatefulWidget {
  const EditTask({super.key});

  @override
  State<EditTask> createState() => _EditTaskState();
}

class _EditTaskState extends State<EditTask> {
  final String idTask = Get.parameters['idtask'] ?? '';
  final TextEditingController _deskripsiTaskController =
      TextEditingController();
  final TextEditingController _persentaseSelesaiController =
      TextEditingController();
  final TextEditingController _tautanTaskController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  StatusTaskController statusTaskController = StatusTaskController();
  KategoriTaskController kategoriTaskController = KategoriTaskController();
  TaskController taskController = TaskController();
  List<StatusTaskModel> statusTask = [];
  List<KategoriTaskModel> kategoriTask = [];

  //file
  PlatformFile? pickedFile;
  File? fileToDisplay;
  String? fileName;
  String filePath = "";
  bool isLoading = false;
  String idPekerjaan = "";
  String idUser = "";
  String idStatusTask = "";
  String idKategoriTask = "";
  bool completed = false;

  //getdata task
  Future<List<TaskModel>> getDataTask() async {
    List<TaskModel> dataTask = await taskController.getTaskById(idTask);
    setState(() {
      idPekerjaan = dataTask[0].id_pekerjaan.toString();
    });
    return dataTask;
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

  //get id user
  getIdUser() async {
    final prefs = await SharedPreferences.getInstance();
    var idUser = prefs.getString("id_user");
    return idUser;
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

  //pick file
  void _pickFile() async {
    setState(() {
      isLoading = true;
    });
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx'],
    );
    if (result != null) {
      setState(() {
        pickedFile = result.files.first;
        fileName = pickedFile!.name;
        filePath = pickedFile!.path.toString();
        fileToDisplay = File(pickedFile!.path.toString());
      });
    } else {
      print('User canceled the picker');
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    try {
      statusTask = [];
      kategoriTask = [];
      getDataStatusTask().then((data) {
        setState(() {
          statusTask = data;
        });
      });
      getDataKategoriTask().then((data) {
        setState(() {
          kategoriTask = data;
        });
      });
      getIdUser().then((value) {
        setState(() {
          idUser = value;
        });
      });
      getDataTask().then((value) {
        setState(() {
          _deskripsiTaskController.text = value[0].deskripsi_task.toString();
          _persentaseSelesaiController.text =
              value[0].persentase_selesai.toString();
          _selectedDateStart = DateTime.parse(value[0].tgl_planing.toString());
          idStatusTask = value[0].id_status_task.toString();
          idKategoriTask = value[0].id_kategori_task.toString();
          _tautanTaskController.text = value[0].tautan_task.toString();
          _persentaseSelesaiController.text =
              value[0].persentase_selesai.toString();
        });
      });
    } catch (e) {
      print('Exception: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: GlobalColors.mainColor,
        title: Text('Ubah Task', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                //deskripsi task
                buildLabel('Deskripsi Task *'),
                buildFormField(_deskripsiTaskController, 'Deskripsi Task',
                    TextInputType.multiline),
                SizedBox(height: 16),

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
                SizedBox(height: 16),
                //status task
                buildLabel('Status Task *'),
                FutureBuilder<List<StatusTaskModel>>(
                  future: getDataStatusTask(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error loading data');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Text('No data available');
                    } else {
                      List<StatusTaskModel> statusList = snapshot.data!;
                      return DropdownButtonFormField<String>(
                        value: idStatusTask,
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
                        decoration: InputDecoration(
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
                SizedBox(height: 16),
                //kategori task
                buildLabel('Kategori Task *'),
                FutureBuilder<List<KategoriTaskModel>>(
                  future: getDataKategoriTask(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error loading data');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Text('No data available');
                    } else {
                      List<KategoriTaskModel> kategoriList = snapshot.data!;
                      return DropdownButtonFormField<String>(
                        value: idKategoriTask,
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
                        decoration: InputDecoration(
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
                SizedBox(height: 16),
                //tautan task
                buildLabel('Tautan Task *'),
                buildFormField(
                    _tautanTaskController, "Tautan Task", TextInputType.url),
                SizedBox(height: 16),
                //persentase selesai
                buildLabel('Persentase Selesai *'),
                buildFormField(_persentaseSelesaiController,
                    'Persentase Selesai', TextInputType.number),
                SizedBox(height: 5),
                // Checkbox completed
                Row(
                  children: [
                    Checkbox(
                      value: completed,
                      activeColor: Colors.green,
                      onChanged: (value) {
                        setState(() {
                          completed = value!;
                        });
                      },
                    ),
                    Text('Task Selesai?', style: TextStyle(fontSize: 16)),
                  ],
                ),
                if (completed)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      //bukti selesai
                      buildLabel('Bukti Selesai *'),
                      GestureDetector(
                        onTap: () {
                          _pickFile();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey[200],
                          ),
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(Icons.upload_file),
                              SizedBox(width: 16),
                              if (pickedFile != null)
                                Expanded(
                                  child: Text(
                                    fileName!,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )
                              else
                                Expanded(
                                  child: Text(
                                    'Pilih file',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: 35),
                //button
                completed
                    ? GestureDetector(
                        onTap: () async {
                          setState(() {
                            isLoading = true;
                          });
                          if (_formKey.currentState!.validate()) {
                            bool submitTask = await taskController.submitTask(
                              idTask,
                              idPekerjaan,
                              idUser,
                              idStatusTask,
                              idKategoriTask,
                              _selectedDateStart!, //tgl planing
                              _deskripsiTaskController.text,
                              _tautanTaskController.text,
                              _persentaseSelesaiController.text.toString(),
                              filePath, //bukti selesai
                            );
                            if (submitTask) {
                              Get.toNamed('/task/$idPekerjaan');
                              QuickAlert.show(
                                  context: context,
                                  title: "Submit Task Berhasil",
                                  type: QuickAlertType.success);
                            } else {
                              QuickAlert.show(
                                  context: context,
                                  title: "Submit Task Gagal",
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
                            color: Colors.green,
                          ),
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Submit Task',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    : GestureDetector(
                        onTap: () async {
                          setState(() {
                            isLoading = true;
                          });
                          if (_formKey.currentState!.validate()) {
                            bool editTask = await taskController.editTask(
                              idTask,
                              idPekerjaan,
                              idUser,
                              idStatusTask,
                              idKategoriTask,
                              _selectedDateStart!, //tgl planing
                              _deskripsiTaskController.text,
                              _tautanTaskController.text,
                              _persentaseSelesaiController.text.toString(),
                            );
                            if (editTask) {
                              Get.toNamed('/task/$idPekerjaan');
                              QuickAlert.show(
                                  context: context,
                                  title: "Edit Task Berhasil",
                                  type: QuickAlertType.success);
                            } else {
                              QuickAlert.show(
                                  context: context,
                                  title: "Edit Task Gagal",
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
                          child: Text(
                            'Ubah Task',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
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
      decoration: InputDecoration(
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
      padding: EdgeInsets.only(bottom: 5),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
