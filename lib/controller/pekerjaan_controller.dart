import 'package:destask/model/pekerjaan_model.dart';
import 'package:destask/utils/constant_api.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// API link
const url = '$baseURL/api/pekerjaan';

Future getToken() async {
  final prefs = await SharedPreferences.getInstance();
  var token = prefs.getString("token");
  return token;
}

class PekerjaanController {
  Future<List<dynamic>> getAllPekerjaan() async {
    try {
      var token = await getToken();
      var response = await http
          .get(Uri.parse(url), headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        Iterable list = json.decode(response.body);
        List<dynamic> pekerjaan = List<dynamic>.from(list.map((e) => e));
        return pekerjaan;
      } else {
        // Handle error
        return [];
      }
    } catch (e) {
      print(e);
      return [];
    }
  }

  //get pekerjaan by id
  Future<Map<String, dynamic>> getPekejaanById(String idPekerjaan) async {
    try {
      var token = await getToken();
      var response = await http.get(
        Uri.parse('$url/$idPekerjaan'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> pekerjaan = json.decode(response.body);
        return pekerjaan;
      } else {
        return {};
      }
    } catch (e) {
      return {};
    }
  }

  Future<List<dynamic>> getOnProgress() async {
    try {
      var token = await getToken();
      print(token);
      var response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        Iterable list = json.decode(response.body);
        List<dynamic> pekerjaan = List<dynamic>.from(list
            .where((element) => element['status'] == "On Progress")
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
}