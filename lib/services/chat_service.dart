import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ChatMessage {
  final String role;
  final String content;

  ChatMessage({required this.role, required this.content});

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
      };
}

class ChatService {
  String get baseUrl => dotenv.env['BACKEND_URL'] ?? 'http://localhost:8000';

  final List<ChatMessage> _history = [];

  List<ChatMessage> get history => List.unmodifiable(_history);

  Future<String> sendMessage(String message) async {
    try {
      _history.add(ChatMessage(role: 'user', content: message));

      final response = await http.post(
        Uri.parse('$baseUrl/chatbot/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': message,
          'history': _history.map((m) => m.toJson()).toList(),
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final assistantMessage = data['message'] as String;
        _history.add(ChatMessage(role: 'assistant', content: assistantMessage));
        return assistantMessage;
      } else {
        return 'Error del servidor: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      return 'Error de conexión: $e\n\nAsegúrate de que el servidor FastAPI esté corriendo y la URL en .env sea correcta.';
    }
  }

  void clearHistory() {
    _history.clear();
  }
}
