import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:quickalert/quickalert.dart';

import '../model/user_model.dart';
import '../utils/constant_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;

const url = '$baseURL/api/user';

Future getToken() async {
  final prefs = await SharedPreferences.getInstance();
  var token = prefs.getString("token");
  return token;
}

Future getIdUser() async {
  final prefs = await SharedPreferences.getInstance();
  var idUser = prefs.getString("id_user");
  return idUser;
}

class UserController {
  Future getAllUser() async {
    try {
      var token = await getToken();
      var response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        Iterable it = json.decode(response.body);
        List<UserModel> user =
            List<UserModel>.from(it.map((e) => UserModel.fromJson(e)));
        return user;
      } else {
        // Handle error
        return [];
      }
    } catch (e) {
      // Handle exception
      return [];
    }
  }

  Future getUserById(String idUser) async {
    try {
      var token = await getToken();
      var response = await http.get(
        Uri.parse('$url/$idUser'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        Iterable it = json.decode(response.body);
        List<UserModel> user =
            List<UserModel>.from(it.map((e) => UserModel.fromJson(e)).toList());
        return user;
      } else if (response.statusCode == 401) {
        SharedPreferences pref = await SharedPreferences.getInstance();
        pref.clear();
        Get.offAllNamed('/login');
        QuickAlert.show(
          context: Get.context!,
          title: 'Token Expired, Login Ulang',
          type: QuickAlertType.error,
        );
      } else {
        // Handle error
        return {};
      }
    } catch (e) {
      print(e);
    }
  }

  Future editProfile(
    String idusergroup,
    String nama,
    String email,
    String username,
  ) async {
    try {
      var token = await getToken();
      var user = await getIdUser();
      var uri = Uri.parse('$url/$user');
      final data = {
        'id_user': user,
        'id_usergroup': idusergroup,
        'nama': nama,
        'email': email,
        'username': username,
      };
      var response = await http.put(uri,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data));

      if (response.statusCode == 200) {
        print(uri);
        //delete shared preferences
        final prefs = await SharedPreferences.getInstance();
        prefs.remove('nama');
        prefs.remove('id_usergroup');
        prefs.remove('email');
        prefs.remove('username');
        prefs.setString('nama', nama);
        prefs.setString('id_usergroup', idusergroup);
        prefs.setString('email', email);
        prefs.setString('username', username);
        return true;
      } else if (response.statusCode == 401) {
        SharedPreferences pref = await SharedPreferences.getInstance();
        pref.clear();
        Get.offAllNamed('/login');
        QuickAlert.show(
          context: Get.context!,
          title: 'Token Expired, Login Ulang',
          type: QuickAlertType.error,
        );
      } else {
        print(uri);
        print('Failed to edit profile. Status code: ${response.statusCode}');
        print(response.body);
        return false;
      }
    } catch (e) {
      throw Exception('Error editing profile: $e');
    }
  }

  //update foto profil
  Future uploadImage(File imageFile) async {
    var stream = http.ByteStream(imageFile.openRead());
    var length = await imageFile.length();
    var id_user = await getIdUser();
    var uri = Uri.parse('$url/fotoprofil');
    var token = await getToken();

    var request = http.MultipartRequest("POST", uri);
    request.headers['Authorization'] = 'Bearer $token';

    var MultiPartFile = http.MultipartFile('foto_profil', stream, length,
        filename: basename(imageFile.path));

    Map<String, String> body = {
      'id_user': id_user,
    };

    request.fields.addAll(body);
    request.files.add(MultiPartFile);

    try {
      var streamedResponse = await request.send();
      if (streamedResponse.statusCode == 200) {
        var response = await http.Response.fromStream(streamedResponse);
        Map<String, dynamic> parsed = jsonDecode(response.body);
        print(parsed);
        return true;
      } else {
        print(streamedResponse.statusCode);
        print(streamedResponse.reasonPhrase);
        var response = await http.Response.fromStream(streamedResponse);
        Map<String, dynamic> parsed = jsonDecode(response.body);
        print(parsed);
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }
}
