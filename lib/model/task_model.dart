class TaskModel {
  String? id_task;
  String? id_pekerjaan;
  String? id_user;
  String? id_status_task;
  String? id_kategori_task;
  String? tgl_planing;
  String? tgl_selesai;
  String? tgl_verifikasi_diterima;
  String? status_verifikasi;
  String? persentase_selesai;
  String? deskripsi_task;
  String? alasan_verifikasi;
  String? bukti_selesai;
  String? tautan_task;
  String? created_at;
  DataTambahan data_tambahan;

  TaskModel({
    this.id_task,
    this.id_pekerjaan,
    this.id_user,
    this.id_status_task,
    this.id_kategori_task,
    this.tgl_planing,
    this.tgl_selesai,
    this.tgl_verifikasi_diterima,
    this.status_verifikasi,
    this.persentase_selesai,
    this.deskripsi_task,
    this.alasan_verifikasi,
    this.bukti_selesai,
    this.tautan_task,
    this.created_at,
    required this.data_tambahan,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id_task: json['id_task'],
      id_pekerjaan: json['id_pekerjaan'],
      id_user: json['id_user'],
      id_status_task: json['id_status_task'],
      id_kategori_task: json['id_kategori_task'],
      tgl_planing: json['tgl_planing'] ?? '',
      tgl_selesai: json['tgl_selesai'] != null
          ? DateTime.parse(json['tgl_selesai']).toString()
          : '',
      tgl_verifikasi_diterima: json['tgl_verifikasi_diterima'] ?? '',
      status_verifikasi: json['status_verifikasi'] ?? '',
      persentase_selesai: json['persentase_selesai'],
      deskripsi_task: json['deskripsi_task'],
      alasan_verifikasi: json['alasan_verifikasi'] ?? '',
      bukti_selesai: json['bukti_selesai'] ?? '',
      tautan_task: json['tautan_task'] ?? '',
      created_at: json['created_at'] ?? '',
      data_tambahan: DataTambahan.fromJson(json['data_tambahan']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_task': id_task,
      'id_pekerjaan': id_pekerjaan,
      'id_user': id_user,
      'id_status_task': id_status_task,
      'id_kategori_task': id_kategori_task,
      'tgl_planing': tgl_planing,
      'tgl_selesai': tgl_selesai,
      'tgl_verifikasi_diterima': tgl_verifikasi_diterima,
      'status_verifikasi': status_verifikasi,
      'persentase_selesai': persentase_selesai,
      'deskripsi_task': deskripsi_task,
      'alasan_verifikasi': alasan_verifikasi,
      'bukti_selesai': bukti_selesai,
      'tautan_task': tautan_task,
      'created_at': created_at,
      'data_tambahan': data_tambahan.toJson(),
    };
  }
}

class DataTambahan {
  String nama_user;
  String nama_pekerjaan;
  String nama_status_task;
  String nama_kategori_task;

  DataTambahan({
    required this.nama_user,
    required this.nama_pekerjaan,
    required this.nama_status_task,
    required this.nama_kategori_task,
  });

  factory DataTambahan.fromJson(Map<String, dynamic> json) {
    return DataTambahan(
      nama_user: json['nama_user'] != null ? json['nama_user'] : '',
      nama_pekerjaan:
          json['nama_pekerjaan'] != null ? json['nama_pekerjaan'] : '',
      nama_status_task:
          json['nama_status_task'] != null ? json['nama_status_task'] : '',
      nama_kategori_task:
          json['nama_kategori_task'] != null ? json['nama_kategori_task'] : '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama_user': nama_user,
      'nama_pekerjaan': nama_pekerjaan,
      'nama_status_task': nama_status_task,
      'nama_kategori_task': nama_kategori_task,
    };
  }
}
