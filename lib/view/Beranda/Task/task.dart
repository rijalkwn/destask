import 'package:destask/controller/user_controller.dart';
import 'package:destask/model/user_model.dart';
import 'package:destask/utils/global_colors.dart';
import 'package:intl/intl.dart';
import '../../../controller/pekerjaan_controller.dart';
import '../../../controller/personil_controller.dart';
import '../../../controller/task_controller.dart';
import '../../../model/task_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

class Task extends StatefulWidget {
  const Task({super.key});

  @override
  State<Task> createState() => _TaskState();
}

class _TaskState extends State<Task> {
  final String idPekerjaan = Get.parameters['idpekerjaan'] ?? '';
  CalendarFormat _calendarFormat = CalendarFormat.week;
  TextEditingController searchController = TextEditingController();
  PekerjaanController pekerjaanController = PekerjaanController();
  PersonilController personilController = PersonilController();
  TaskController taskController = TaskController();
  UserController userController = UserController();
  bool isSearchBarVisible = false;

  String namaPekerjaan = '';

  late DateTime _focusedDay;
  DateTime _selectedDay = DateTime.now();

  //pm
  bool isPM = false;
  late bool pm;

  late Future<List<TaskModel>> task;
  late Future<List> user;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
    task = getDataTask();
  }

  void refresh() {
    setState(() {
      // Memperbarui data tugas dengan memanggil getDataTask()
      task = getDataTask();
    });
  }

  getIdUser() async {
    final prefs = await SharedPreferences.getInstance();
    var idUser = prefs.getString("id_user");
    return idUser;
  }

  //cek user pm apa bukan berdasarkan pekerjaan id
  cekPM() async {
    var idUser = await getIdUser();
    print("id user: $idUser");
    print("id pekerjaan: $idPekerjaan");
    var dataPekerjaan = await pekerjaanController.getPekerjaanById(idPekerjaan);
    String idPersonil = dataPekerjaan[0].id_personil.toString();
    var dataPersonil = await personilController.getPersonilById(idPersonil);

    // Make sure 'id_user_pm' is of type String or handle type conversion accordingly
    String idUserPM = dataPersonil[0].id_user_pm.toString();

    if (idUser == idUserPM) {
      return true;
    }
    return false;
  }

  //get data all user
  Future<List<UserModel>> getDataUser(String idUserTask) async {
    List<UserModel> data = await userController.getUserById(idUserTask);
    return data;
  }

  //get data task
  Future<List<TaskModel>> getDataTask() async {
    //cek PM
    pm = await cekPM();

    //untuk pm
    List<TaskModel> taskPM =
        await taskController.getTasksByPekerjaanId(idPekerjaan, _selectedDay);
    //untuk non pm
    List<TaskModel> tasknonPM = await taskController
        .getTasksByUserPekerjaanDate(idPekerjaan, _selectedDay);

    var pekerjaan = await pekerjaanController.getPekerjaanById(idPekerjaan);
    setState(() {
      namaPekerjaan = pekerjaan[0].nama_pekerjaan.toString();
    });
    return pm ? taskPM : tasknonPM;
  }

  Future<void> _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    task = getDataTask();
  }

  bool _selectedDayPredicate(DateTime day) {
    return isSameDay(_selectedDay, day);
  }

  Map<DateTime, List<TaskModel>> _getEventsForDays() {
    Map<DateTime, List<TaskModel>> events = {};

    // Ambil daftar tugas untuk tanggal yang sedang ditampilkan
    List<TaskModel> tasks = []; // Ambil tugas sesuai tanggal

    for (TaskModel task in tasks) {
      DateTime taskDate = DateTime.parse(task.tgl_planing!.toString());
      events.putIfAbsent(taskDate, () => []);
    }

    return events;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: GlobalColors.mainColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: isSearchBarVisible
            ? TextField(
                controller: searchController,
                style: const TextStyle(color: Colors.white),
                autofocus: true,
                onChanged: (value) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: const TextStyle(color: Colors.white60),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white),
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
            : Text(namaPekerjaan, style: const TextStyle(color: Colors.white)),
        actions: !isSearchBarVisible
            ? [
                IconButton(
                  icon: const Icon(Icons.search),
                  color: Colors.white,
                  onPressed: () {
                    setState(() {
                      isSearchBarVisible = !isSearchBarVisible;
                    });
                  },
                ),
              ]
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            //TABEL CALENDAR
            TableCalendar(
              locale: 'id_ID',
              firstDay: DateTime.utc(2000, 01, 01),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              selectedDayPredicate: _selectedDayPredicate,
              onDaySelected: _onDaySelected,
              startingDayOfWeek: StartingDayOfWeek.monday,
              headerStyle: const HeaderStyle(
                formatButtonVisible: true,
              ),
              calendarStyle: const CalendarStyle(
                // outsideDaysVisible: false,
                todayDecoration:
                    BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                weekendTextStyle: TextStyle(color: Colors.red),
                selectedDecoration:
                    BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
              ),
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
              },
            ),
            const Divider(),
            //KETERANGAN
            Column(
              children: [
                const Text(
                  'Keterangan : ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: GlobalColors.mainColor,
                          shape: BoxShape.circle,
                        )),
                    const Text('On Progress'),
                    const SizedBox(
                      width: 10,
                    ),
                    Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        )),
                    const Text('Selesai'),
                    const SizedBox(
                      width: 10,
                    ),
                    Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        )),
                    const Text('Overdue'),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            //LIST TASK
            Expanded(
              child: SingleChildScrollView(child: buildTask()),
            ),
          ],
        ),
      ),
      //TOMBOL ADD TASK
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed('/add_task/$idPekerjaan',
              arguments: Get.parameters['idpekerjaan']);
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget buildTask() {
    return FutureBuilder<List<TaskModel>>(
      future: task,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(fontSize: 16),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'Task Kosong',
              style: TextStyle(fontSize: 16),
            ),
          );
        } else {
          List<TaskModel> allTasks = snapshot.data!;
          final filterTask = allTasks
              .where((task) =>
                  task.deskripsi_task!.toLowerCase().contains(
                        searchController.text.toLowerCase(),
                      ) ||
                  task.tgl_planing!.toString().contains(searchController.text))
              .toList();
          return allTasks.isEmpty
              ? const Center(
                  child: Text(
                    'Task Kosong untuk hari ini',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filterTask.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> taskData = allTasks[index].toJson();

                    //setting color card
                    DateTime currentDate = DateTime.now();
                    DateTime tglPlaning =
                        DateTime.parse(taskData['tgl_planing']);
                    DateTime? tglSelesai;

                    if (taskData['tgl_selesai'] != null) {
                      final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
                      try {
                        tglSelesai = dateFormat.parse(taskData['tgl_selesai']);
                      } catch (e) {
                        print('Error parsing tgl_selesai: $e');
                        tglSelesai = null;
                      }
                    }

                    Color taskColor = GlobalColors.mainColor;

                    if (tglSelesai == null) {
                      //sedang dikerjakan
                      if (currentDate.isBefore(tglPlaning)) {
                        taskColor = GlobalColors.mainColor;
                      }
                      //overdue
                      else {
                        taskColor = Colors.red;
                      }
                    } else {
                      if (tglSelesai.isBefore(tglPlaning)) {
                        taskColor = Colors.green;
                      } else {
                        taskColor = Colors.red;
                      }
                    }
                    return Dismissible(
                      key: Key(taskData['id_task'].toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        padding: const EdgeInsets.only(right: 20),
                        alignment: Alignment.centerRight,
                        color: Colors.red,
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Konfirmasi Hapus Task"),
                              content: const Text(
                                  "Apakah Anda yakin ingin menghapus task ini?"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Close the dialog
                                  },
                                  child: const Text("Batal"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.pop(context); // Close the dialog

                                    await taskController.deleteTask(
                                        taskData['id_task'].toString());
                                    // Refresh task list
                                    refresh();
                                  },
                                  child: const Text("Hapus"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Card(
                        color: taskColor,
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Get.toNamed(
                                    '/detail_task/${taskData['id_task']}',
                                    arguments: taskData);
                              },
                              child: ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${taskData['persentase_selesai']}%',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  taskData['deskripsi_task'].length > 20
                                      ? taskData['deskripsi_task']
                                              .substring(0, 20) +
                                          '...'
                                      : taskData['deskripsi_task'],
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Deadline : ${formatDate(taskData['tgl_planing'])}',
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    pm
                                        ? taskData['data_tambahan'] != null
                                            ? Text(
                                                'PIC : ${taskData['data_tambahan']['nama_user']}',
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              )
                                            : const SizedBox()
                                        : const SizedBox(),
                                  ],
                                ),
                                trailing: GestureDetector(
                                  onTap: () {
                                    Get.toNamed(
                                        '/edit_task/${taskData['id_task']}');
                                  },
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
        }
      },
    );
  }

  //ubah format tanggal
  String formatDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    return DateFormat('d MMMM yyyy', 'id').format(dateTime);
  }
}
