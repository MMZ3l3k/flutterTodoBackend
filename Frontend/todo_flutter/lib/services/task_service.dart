import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/task.dart';

class TaskService {
  static final _base = dotenv.env['BASE_URL']!.trim(); // …/api/tasks
  static final _code = dotenv.env['FUNCTIONS_KEY']!.trim();

  Uri _u([String p = '']) => Uri.parse('$_base$p?code=$_code');

  /* ---------- REST ---------- */

  Future<List<Task>> getAll() async {
    final r = await http.get(_u());
    if (r.statusCode != 200) {
      throw Exception('GET ${r.statusCode}');
    }

    // <── poprawka ↓
    final List data = jsonDecode(r.body) as List; // lista surowych map
    return data
        .map((e) => Task.fromJson(e as Map<String, dynamic>))
        .toList(); // → List<Task>
  }

  Future<void> add(String text) async {
    final r = await http.post(
      _u(),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': text}),
    );

    // ⬇️ Akceptujemy zarówno 200 OK, jak i 201 Created
    if (r.statusCode != 200 && r.statusCode != 201) {
      throw Exception('POST ${r.statusCode}');
    }
  }

  Future<void> delete(String id) async {
    final r = await http.delete(_u('/$id'));
    if (r.statusCode != 204) throw Exception('DELETE ${r.statusCode}');
  }
}
