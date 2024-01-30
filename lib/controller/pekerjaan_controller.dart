import 'package:destask/model/pekerjaan_model.dart';
import 'package:destask/utils/constant_api.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// API link
const url = '$baseURL/api/pekerjaan';
const urluser = '$baseURL/api/pekerjaanuser';

Future getToken() async {
  final prefs = await SharedPreferences.getInstance();
  var token = prefs.getString("token");
  return token;
}

class PekerjaanController {
  // Future getAllPekerjaan() async {
  //   try {
  //     var token = await getToken();
  //     var response = await http
  //         .get(Uri.parse(url), headers: {'Authorization': 'Bearer $token'});
  //     if (response.statusCode == 200) {
  //       Iterable list = json.decode(response.body);
  //       List<PekerjaanModel> pekerjaan = List<PekerjaanModel>.from(
  //           list.map((e) => PekerjaanModel.fromJson(e)).toList());
  //       return pekerjaan;
  //     } else {
  //       // Handle error
  //       return [];
  //     }
  //   } catch (e) {
  //     print(e);
  //     return [];
  //   }
  // }

  //get pekerjaan by id
  Future getPekerjaanById(String idPekerjaan) async {
    try {
      var token = await getToken();
      var response = await http.get(
        Uri.parse('$url/$idPekerjaan'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        Iterable list = json.decode(response.body);
        List<PekerjaanModel> pekerjaan = List<PekerjaanModel>.from(
            list.map((e) => PekerjaanModel.fromJson(e)).toList());
        return pekerjaan;
      } else {
        return {}; // Mengembalikan map kosong jika tidak ada data
      }
    } catch (e) {
      return {}; // Mengembalikan map kosong jika terjadi exception
    }
  }

  //menampilkan list pekerjaan progres di beranda
  Future getOnProgressUser() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      var iduser = pref.getString('id_user');
      var token = await getToken();
      var response = await http.get(
        Uri.parse('$urluser/$iduser'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        Iterable list = json.decode(response.body);
        List<PekerjaanModel> pekerjaan = List<PekerjaanModel>.from(list
            .where((element) => element['id_status_pekerjaan'] == "1")
            .map((e) => PekerjaanModel.fromJson(e)));
        return pekerjaan;
      } else {
        // Handle error
        return [];
      }
    } catch (e) {
      print(e);
      // Returning an empty list in case of an exception
      return [];
    }
  }

//menampilakn list pekerjaan di menu pekerjaan
  Future getAllPekerjaanUser() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      var iduser = pref.getString('id_user');
      var token = await getToken();
      var response = await http.get(
        Uri.parse('$urluser/$iduser'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        Iterable it = json.decode(response.body);
        List<PekerjaanModel> pekerjaan = List<PekerjaanModel>.from(
            it.map((e) => PekerjaanModel.fromJson(e)));
        return pekerjaan;
      } else {
        // Handle error
        return [];
      }
    } catch (e) {
      print(e);
      // Returning an empty list in case of an exception
      return [];
    }
  }
}
