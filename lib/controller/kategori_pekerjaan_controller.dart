import 'dart:convert';

import 'package:destask/model/kategori_pekerjaan_model.dart';
import '../utils/constant_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

const url = '$baseURL/api/kategoripekerjaan';

getToken() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  var token = pref.getString('token');
  return token;
}

class KategoriPekerjaanController {
  //fungsi mendapatkan semua kategori pekerjaan
  Future getAllKategoriPekerjaan() async {
    try {
      var token = await getToken();
      var response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        Iterable it = json.decode(response.body);
        List<KategoriPekerjaanModel> kategori =
            List<KategoriPekerjaanModel>.from(
                it.map((e) => KategoriPekerjaanModel.fromJson(e)));
        print(response.body);
        return kategori;
      } else {
        // Handle error
        return [];
      }
    } catch (e) {
      // Handle exception
      return [];
    }
  }

  //fungsi menampilkan semua kategori pekerjaan
  Future<List<KategoriPekerjaanModel>> showAll() async {
    List<KategoriPekerjaanModel> data = await getAllKategoriPekerjaan();
    return data;
  }

  //fungsi mendapatkan kategori pekerjaan berdasarkan id
  Future getKategoriPekerjaanById(String idKategoriPekerjaan) async {
    try {
      var token = await getToken();
      var response = await http.get(
        Uri.parse('$url/$idKategoriPekerjaan'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        Iterable it = json.decode(response.body);
        List<KategoriPekerjaanModel> kategori =
            List<KategoriPekerjaanModel>.from(
                it.map((e) => KategoriPekerjaanModel.fromJson(e)));
        return kategori;
      } else {
        return {}; // Mengembalikan map kosong jika tidak ada data
      }
    } catch (e) {
      return {}; // Mengembalikan map kosong jika terjadi exception
    }
  }

  //fungsi menampilkan kategori pekerjaan berdasarkan id
  Future<KategoriPekerjaanModel> showById(String idKategoriPekerjaan) async {
    KategoriPekerjaanModel data =
        await getKategoriPekerjaanById(idKategoriPekerjaan);
    return data;
  }
}
