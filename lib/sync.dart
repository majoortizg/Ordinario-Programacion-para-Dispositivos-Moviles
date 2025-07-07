import 'package:recuerdos_ordinario3/recuerdo.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SincRecuerdos {
  String server = "http://192.168.1.66:8080/";
  String endpoint = "recuerdo";

  Future<Recuerdo> insert(Recuerdo recuerdo) async {
    String s = jsonEncode(recuerdo.toJson());

    final response = await http.put(
      Uri.parse("${server}${endpoint}/insert"),
      headers: <String, String>{'Content-Type': 'application/json'},
      body: s,
    );

    if (response.statusCode == 200) {
      recuerdo.Sincronizado = 1;
      recuerdo.Id = int.parse(response.body);
      return recuerdo;
    } else {
      print("Error insertando recuerdo:");
      print("Código de respuesta: ${response.statusCode}");
      print("Cuerpo de respuesta: ${response.body}");
      print("Datos enviados: $s");
      throw Exception('Failed to insert data');
    }
  }


  Future<Recuerdo> update(Recuerdo recuerdo) async {
    String s = jsonEncode(recuerdo.toJson());
    final response = await http.put(
      Uri.parse("${server}${endpoint}/update"),
      headers: <String, String>{'Content-Type': 'application/json'},
      body: s,
    );
    if (response.statusCode == 200) {
      recuerdo.Sincronizado = 1;
      return recuerdo;
    } else {
      throw Exception('Failed to update data');
    }
  }

  Future<Map<String, dynamic>> getAll() async {
    final response = await http.get(Uri.parse("${server}${endpoint}/getAll"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<Map<String, dynamic>> getByID(int id) async {
    final response = await http.get(Uri.parse("${server}${endpoint}/getAll/${id}"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<String> delete(int id) async {
    final response = await http.get(Uri.parse("${server}${endpoint}/delete/${id}"));

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to delete data');
    }
  }
}
