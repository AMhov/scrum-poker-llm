import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';
import 'blocs/app_bloc.dart';
import 'services/api_service.dart';
import 'services/socket_service.dart';
import 'services/session_service.dart';
import 'services/connection_status.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/room_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/about_screen.dart';

int _getInitialIndex(String uri) {
  if (uri.startsWith('/room/')) return 1;
  if (uri.startsWith('/settings')) return 2;
  return 0;
}

Future<String?> _redirect(BuildContext context, GoRouterState state) async {
  final deepLink = state.uri.toString();
  if (deepLink.startsWith('scrum-poker://room/')) {
    final roomId = deepLink.replaceFirst('scrum-poker://room/', '');
    return '/room/$roomId';
  }
  return null;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  final baseUrl = prefs.getString('backend_url') ?? 'http://localhost:5000';
  
  final apiService = ApiService(baseUrl);
  final socketService = SocketService(baseUrl);
  final sessionService = SessionService();
  final connectionStatus = ConnectionStatus(
    apiService: apiService,
    socketService: socketService,
  );
  
  final router = GoRouter(
    initialLocation: '/',
    redirect: _redirect,
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainNavigationScreen(
            initialState: _getInitialIndex(state.uri.toString()),
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            pageBuilder: (_, __) => const MaterialPage(child: HomeScreen()),
          ),
          GoRoute(
            path: '/room/:roomId',
            name: 'room',
            pageBuilder: (_, state) => MaterialPage(
              child: RoomScreen(
                roomId: state.pathParameters['roomId']!,
              ),
            ),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            pageBuilder: (_, __) => const MaterialPage(child: SettingsScreen()),
          ),
        ],
      ),
      GoRoute(
        path: '/about',
        name: 'about',
        pageBuilder: (_, __) => const MaterialPage(child: AboutScreen()),
      ),
    ],
  );
  
  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>.value(value: apiService),
        Provider<SocketService>.value(value: socketService),
        Provider<SessionService>.value(value: sessionService),
        Provider<ConnectionStatus>.value(value: connectionStatus),
        BlocProvider(
          create: (_) => AppBloc(
            apiService: apiService,
            socketService: socketService,
            sessionService: sessionService,
          )..add(LoadSavedPlayerEvent()),
        ),
      ],
      child: ScrumPokerApp(router: router),
    ),
  );
}

class ScrumPokerApp extends StatelessWidget {
  final GoRouter router;
  const ScrumPokerApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Scrum Poker',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
      ],
      supportedLocales: const [
        Locale('ru'),
        Locale('en'),
      ],
      routerConfig: router,
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  final Widget child;
  final int initialState;
  const MainNavigationScreen({
    super.key,
    required this.child,
    required this.initialState,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialState;
  }

  @override
  void didUpdateWidget(MainNavigationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currentUri = ModalRoute.of(context)?.settings.arguments;
    if (currentUri != null && currentUri is String) {
      _currentIndex = _getInitialIndex(currentUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          final go = GoRouter.of(context);
          switch (index) {
            case 0:
              go.go('/');
              break;
            case 1:
              final state = context.read<AppBloc>().state;
              if (state.room != null) {
                go.go('/room/${state.room!.id}');
              } else {
                go.go('/');
              }
              break;
            case 2:
              go.go('/settings');
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups),
            label: 'Комната',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Настройки',
          ),
        ],
      ),
    );
  }
}