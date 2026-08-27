import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  late io.Socket _socket;
  final String baseUrl;
  bool _connected = false;

  bool get isConnected => _connected;

  SocketService(this.baseUrl);

  void connect(String roomId) {
    _socket = io.io(baseUrl, <String, dynamic>{
      'transports': ['polling'],
      'autoConnect': true,
      'reconnection': true,
      'reconnectionAttempts': 10,
      'reconnectionDelay': 2000,
      'reconnectionDelayMax': 10000,
      'timeout': 10000,
    });

    _socket.onConnect((_) {
      _connected = true;
      print('Socket connected');
      _socket.emit('join_room', {'room_id': roomId});
    });

    _socket.onDisconnect((_) {
      _connected = false;
      print('Socket disconnected');
    });

    _socket.onConnectError((data) {
      _connected = false;
      print('Socket connect error: $data');
    });

    _socket.onReconnect((_) {
      _connected = true;
      print('Socket reconnected');
      _socket.emit('join_room', {'room_id': roomId});
    });

    _socket.on('room_created', (data) {
      print('Event: room_created');
      _emitEvent('room_created', data);
    });

    _socket.on('player_joined', (data) {
      print('Event: player_joined');
      _emitEvent('player_joined', data);
    });

    _socket.on('player_left', (data) {
      print('Event: player_left');
      _emitEvent('player_left', data);
    });

    _socket.on('round_started', (data) {
      print('Event: round_started');
      _emitEvent('round_started', data);
    });

    _socket.on('vote_cast', (data) {
      print('Event: vote_cast');
      _emitEvent('vote_cast', data);
    });

    _socket.on('round_revealed', (data) {
      print('Event: round_revealed');
      _emitEvent('round_revealed', data);
    });
  }

  void _emitEvent(String event, dynamic data) {
    final controller = _eventControllers[event];
    controller?.add(data);
  }

  Stream<dynamic> on(String event) {
    return _eventControllers.putIfAbsent(
      event,
      () => StreamController<dynamic>(),
    ).stream;
  }

  void emit(String event, dynamic data) {
    if (_connected) {
      _socket.emit(event, data);
    }
  }

  void disconnect() {
    _connected = false;
    _socket.disconnect();
    _socket.dispose();
    for (final controller in _eventControllers.values) {
      controller.close();
    }
  }

  final Map<String, StreamController<dynamic>> _eventControllers = {};
}
