import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // URL del backend - configurable via .env
  String get baseUrl => dotenv.env['BACKEND_URL'] ?? 'https://agenda-academica-backend.onrender.com';

  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  // Headers por defecto
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Cursos
  Future<List<dynamic>> getCursos() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/cursos'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Error al obtener cursos: ${response.statusCode}');
  }

  Future<dynamic> getCurso(String cursoId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/cursos/$cursoId'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Error al obtener curso: ${response.statusCode}');
  }

  Future<dynamic> createCurso(Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/cursos'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    throw Exception('Error al crear curso: ${response.statusCode}');
  }

  Future<dynamic> updateCurso(String cursoId, Map<String, dynamic> data) async {
    final response = await _client.put(
      Uri.parse('$baseUrl/cursos/$cursoId'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Error al actualizar curso: ${response.statusCode}');
  }

  Future<void> deleteCurso(String cursoId) async {
    final response = await _client.delete(
      Uri.parse('$baseUrl/cursos/$cursoId'),
      headers: _headers,
    );
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar curso: ${response.statusCode}');
    }
  }

  // Actividades
  Future<List<dynamic>> getActividades(String cursoId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/cursos/$cursoId/actividades'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Error al obtener actividades: ${response.statusCode}');
  }

  Future<dynamic> createActividad(String cursoId, Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/cursos/$cursoId/actividades'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    throw Exception('Error al crear actividad: ${response.statusCode}');
  }

  Future<dynamic> updateActividad(String cursoId, String actividadId, Map<String, dynamic> data) async {
    final response = await _client.put(
      Uri.parse('$baseUrl/cursos/$cursoId/actividades/$actividadId'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Error al actualizar actividad: ${response.statusCode}');
  }

  Future<void> deleteActividad(String cursoId, String actividadId) async {
    final response = await _client.delete(
      Uri.parse('$baseUrl/cursos/$cursoId/actividades/$actividadId'),
      headers: _headers,
    );
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar actividad: ${response.statusCode}');
    }
  }

  // Alumnos
  Future<List<dynamic>> getAlumnos() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/alumnos'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Error al obtener alumnos: ${response.statusCode}');
  }

  Future<dynamic> getAlumno(String alumnoId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/alumnos/$alumnoId'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Error al obtener alumno: ${response.statusCode}');
  }

  Future<dynamic> createAlumno(Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/alumnos'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    throw Exception('Error al crear alumno: ${response.statusCode}');
  }

  Future<dynamic> updateAlumno(String alumnoId, Map<String, dynamic> data) async {
    final response = await _client.put(
      Uri.parse('$baseUrl/alumnos/$alumnoId'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Error al actualizar alumno: ${response.statusCode}');
  }

  Future<void> deleteAlumno(String alumnoId) async {
    final response = await _client.delete(
      Uri.parse('$baseUrl/alumnos/$alumnoId'),
      headers: _headers,
    );
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar alumno: ${response.statusCode}');
    }
  }

  // Seguimientos
  Future<List<dynamic>> getSeguimientos({String? alumnoId, String? cursoId}) async {
    String url = '$baseUrl/seguimientos';
    if (alumnoId != null || cursoId != null) {
      final params = <String>[];
      if (alumnoId != null) params.add('alumno_id=$alumnoId');
      if (cursoId != null) params.add('curso_id=$cursoId');
      url += '?${params.join('&')}';
    }
    
    final response = await _client.get(
      Uri.parse(url),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Error al obtener seguimientos: ${response.statusCode}');
  }

  Future<dynamic> createSeguimiento(Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/seguimientos'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    throw Exception('Error al crear seguimiento: ${response.statusCode}');
  }

  Future<dynamic> updateSeguimiento(String seguimientoId, Map<String, dynamic> data) async {
    final response = await _client.put(
      Uri.parse('$baseUrl/seguimientos/$seguimientoId'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Error al actualizar seguimiento: ${response.statusCode}');
  }

  Future<void> deleteSeguimiento(String seguimientoId) async {
    final response = await _client.delete(
      Uri.parse('$baseUrl/seguimientos/$seguimientoId'),
      headers: _headers,
    );
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar seguimiento: ${response.statusCode}');
    }
  }

  // Docentes
  Future<List<dynamic>> getDocentes() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/docentes'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Error al obtener docentes: ${response.statusCode}');
  }

  Future<dynamic> createDocente(Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/docentes'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    throw Exception('Error al crear docente: ${response.statusCode}');
  }

  // Estadísticas
  Future<dynamic> getEstadisticasGlobales() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/estadisticas/global'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Error al obtener estadísticas: ${response.statusCode}');
  }

  Future<dynamic> getEstadisticasCurso(String cursoId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/estadisticas/curso/$cursoId'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Error al obtener estadísticas del curso: ${response.statusCode}');
  }

  // Chatbot
  Future<String> sendChatMessage(String message, {List<Map<String, String>>? history}) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/chatbot/chat'),
      headers: _headers,
      body: jsonEncode({
        'message': message,
        'history': history ?? [],
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['message'] as String;
    }
    throw Exception('Error al enviar mensaje: ${response.statusCode}');
  }
}
