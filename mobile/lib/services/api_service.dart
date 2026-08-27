import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/room.dart';

class ApiService {
  final String baseUrl;
  final http.Client _client = http.Client();

  ApiService(this.baseUrl);

  Future<Room> getRoom(String roomId) async {
    try {
      final response = await _client.get(Uri.parse('$baseUrl/api/rooms/$roomId')).timeout(
        const Duration(seconds: 10),
      );
      if (response.statusCode == 200) {
        return Room.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        throw Exception('Failed to load room: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Request timed out: server not responding');
    } on http.ClientException {
      throw Exception('Network error: unable to connect to server');
    }
  }

  /// Проверка доступности бэкенда
  Future<bool> ping() async {
    try {
      final response = await _client.get(Uri.parse('$baseUrl/api/rooms')).timeout(
        const Duration(seconds: 5),
      );
      return response.statusCode == 200 || response.statusCode == 404;
    } catch (_) {
      return false;
    }
  }

  /// Возвращает {room_id, room_name, host_id, invite_url}
  Future<Map<String, dynamic>> createRoom({
    required String name,
    required String hostNickname,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/rooms'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'host_nickname': hostNickname,
        }),
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to create room: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Request timed out: server not responding');
    } on http.ClientException {
      throw Exception('Network error: unable to connect to server');
    }
  }

  /// Возвращает {player_id, nickname, role}
  Future<Map<String, dynamic>> joinRoom(
    String roomId, {
    required String nickname,
    required String role,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/rooms/$roomId/join'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nickname': nickname,
          'role': role,
        }),
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to join room: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Request timed out: server not responding');
    } on http.ClientException {
      throw Exception('Network error: unable to connect to server');
    }
  }

  Future<void> startRound(
    String roomId, {
    required String taskDescription,
    required String hostId,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/rooms/$roomId/rounds'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'task_description': taskDescription,
          'host_id': hostId,
        }),
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode != 201) {
        throw Exception('Failed to start round: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Request timed out: server not responding');
    } on http.ClientException {
      throw Exception('Network error: unable to connect to server');
    }
  }

  Future<void> castVote(
    int roundId, {
    required String playerId,
    required int value,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/rounds/$roundId/votes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'player_id': playerId,
          'value': value,
        }),
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode != 201) {
        throw Exception('Failed to cast vote: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Request timed out: server not responding');
    } on http.ClientException {
      throw Exception('Network error: unable to connect to server');
    }
  }

  Future<List<Map<String, dynamic>>> revealVotes(
    int roundId, {
    required String hostId,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/rounds/$roundId/reveal'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'host_id': hostId,
        }),
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        throw Exception('Failed to reveal votes: ${response.statusCode}');
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return (body['votes'] as List).cast<Map<String, dynamic>>();
    } on TimeoutException {
      throw Exception('Request timed out: server not responding');
    } on http.ClientException {
      throw Exception('Network error: unable to connect to server');
    }
  }

  void dispose() {
    _client.close();
  }
}
