import 'package:flutter/material.dart';

class AppLocalizations {
  final String languageCode;

  AppLocalizations(this.languageCode);

  static AppLocalizations of(BuildContext context) {
    return AppLocalizations(
      Localizations.localeOf(context).languageCode,
    );
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'ru': {
      'appTitle': 'Scrum Poker',
      'createRoom': 'Создать комнату',
      'roomName': 'Название комнаты',
      'roomNameHint': 'Спринт 12',
      'nickname': 'Ваш псевдоним',
      'nicknameHint': 'Алексей',
      'create': 'Создать',
      'creating': 'Создание...',
      'joinRoom': 'Вступить в комнату',
      'inviteLink': 'Ссылка на комнату',
      'inviteLinkHint': 'https://.../room/abc-123',
      'join': 'Вступить',
      'joining': 'Вступление...',
      'settings': 'Настройки',
      'server': 'Сервер',
      'backendUrl': 'URL бэкенда',
      'backendUrlHint': 'http://localhost:5000',
      'darkMode': 'Тёмная тема',
      'darkModeSubtitle': 'Использовать тёмное оформление',
      'save': 'Сохранить',
      'saving': 'Сохранение...',
      'settingsSaved': 'Настройки сохранены. Перезапустите приложение.',
      'about': 'О приложении',
      'version': 'Версия',
      'sourceCode': 'Исходный код',
      'madeWithKoda': 'Сделано с помощью Koda',
      'roomNotFound': 'Комната не найдена',
      'roundActive': 'Раунд активен',
      'roundFinished': 'Раунд завершён',
      'revealCards': 'Вскрыть карты',
      'startRound': 'Начать раунд',
      'startRoundTitle': 'Начать раунд',
      'taskDescription': 'Описание задачи (необязательно)',
      'cancel': 'Отмена',
      'start': 'Начать',
      'revealTitle': 'Вскрыть карты?',
      'revealContent': 'Все голоса будут показаны участникам.',
      'reveal': 'Вскрыть',
      'results': 'Результаты',
      'average': 'Среднее',
      'median': 'Медиана',
      'min': 'Мин',
      'max': 'Макс',
      'host': 'Ведущий',
      'player': 'Участник',
      'observer': 'Наблюдатель',
      'loading': 'Загрузка...',
      'createError': 'Ошибка создания комнаты',
      'joinError': 'Ошибка вступления в комнату',
      'invalidUrl': 'Неверный формат URL. Используйте http:// или https://',
      'saveAndRestart': 'Сохранить и перезапустить',
      'settingsSavedRestart': 'Настройки сохранены. Перезапустите приложение для применения.',
      'restart': 'Перезапустить',
      'restartApp': 'Перезапуск приложения',
      'restartAppContent': 'Для применения новых настроек перезапустите приложение: закройте его и откройте снова.',
      'ok': 'OK',
      'howToFindIp': 'Как узнать IP-адрес?',
      'ipStep1': '1. Linux (в терминале):',
      'ipStep2': '2. Альтернативный способ (Linux):',
      'ipStep3': '3. Windows:',
      'ipStep3Content': 'Откройте командную строку и введите: ipconfig. Найдите IPv4-адрес адаптера Wi-Fi.',
      'ipNote': 'Используйте IPv4-адрес (например, 192.168.1.100). Убедитесь, что телефон и компьютер в одной Wi-Fi сети.',
      'urlHistory': 'История подключений',
      'close': 'Закрыть',
      'connected': 'Подключено',
      'disconnected': 'Нет подключения',
    },
    'en': {
      'appTitle': 'Scrum Poker',
      'createRoom': 'Create Room',
      'roomName': 'Room Name',
      'roomNameHint': 'Sprint 12',
      'nickname': 'Your Nickname',
      'nicknameHint': 'Alex',
      'create': 'Create',
      'creating': 'Creating...',
      'joinRoom': 'Join Room',
      'inviteLink': 'Room Link',
      'inviteLinkHint': 'https://.../room/abc-123',
      'join': 'Join',
      'joining': 'Joining...',
      'settings': 'Settings',
      'server': 'Server',
      'backendUrl': 'Backend URL',
      'backendUrlHint': 'http://localhost:5000',
      'darkMode': 'Dark Mode',
      'darkModeSubtitle': 'Use dark theme',
      'save': 'Save',
      'saving': 'Saving...',
      'settingsSaved': 'Settings saved. Restart the app.',
      'about': 'About',
      'version': 'Version',
      'sourceCode': 'Source Code',
      'madeWithKoda': 'Made with Koda',
      'roomNotFound': 'Room not found',
      'roundActive': 'Round active',
      'roundFinished': 'Round finished',
      'revealCards': 'Reveal Cards',
      'startRound': 'Start Round',
      'startRoundTitle': 'Start Round',
      'taskDescription': 'Task description (optional)',
      'cancel': 'Cancel',
      'start': 'Start',
      'revealTitle': 'Reveal Cards?',
      'revealContent': 'All votes will be shown to participants.',
      'reveal': 'Reveal',
      'results': 'Results',
      'average': 'Average',
      'median': 'Median',
      'min': 'Min',
      'max': 'Max',
      'host': 'Host',
      'player': 'Player',
      'observer': 'Observer',
      'loading': 'Loading...',
      'createError': 'Error creating room',
      'joinError': 'Error joining room',
      'invalidUrl': 'Invalid URL format. Use http:// or https://',
      'saveAndRestart': 'Save & Restart',
      'settingsSavedRestart': 'Settings saved. Restart the app to apply.',
      'restart': 'Restart',
      'restartApp': 'Restart App',
      'restartAppContent': 'To apply new settings, restart the app: close it and open it again.',
      'ok': 'OK',
      'howToFindIp': 'How to find IP address?',
      'ipStep1': '1. Linux (in terminal):',
      'ipStep2': '2. Alternative (Linux):',
      'ipStep3': '3. Windows:',
      'ipStep3Content': 'Open Command Prompt and type: ipconfig. Find the IPv4 address of your Wi-Fi adapter.',
      'ipNote': 'Use the IPv4 address (e.g., 192.168.1.100). Make sure the phone and computer are on the same Wi-Fi network.',
      'urlHistory': 'Connection History',
      'close': 'Close',
      'connected': 'Connected',
      'disconnected': 'Disconnected',
    },
  };

  String t(String key) {
    return _localizedValues[languageCode]?[key] ?? _localizedValues['en']?[key] ?? key;
  }

  String get appTitle => t('appTitle');
  String get createRoom => t('createRoom');
  String get roomName => t('roomName');
  String get roomNameHint => t('roomNameHint');
  String get nickname => t('nickname');
  String get nicknameHint => t('nicknameHint');
  String get create => t('create');
  String get creating => t('creating');
  String get joinRoom => t('joinRoom');
  String get inviteLink => t('inviteLink');
  String get inviteLinkHint => t('inviteLinkHint');
  String get join => t('join');
  String get joining => t('joining');
  String get settings => t('settings');
  String get server => t('server');
  String get backendUrl => t('backendUrl');
  String get backendUrlHint => t('backendUrlHint');
  String get darkMode => t('darkMode');
  String get darkModeSubtitle => t('darkModeSubtitle');
  String get save => t('save');
  String get saving => t('saving');
  String get settingsSaved => t('settingsSaved');
  String get about => t('about');
  String get version => t('version');
  String get sourceCode => t('sourceCode');
  String get madeWithKoda => t('madeWithKoda');
  String get roomNotFound => t('roomNotFound');
  String get roundActive => t('roundActive');
  String get roundFinished => t('roundFinished');
  String get revealCards => t('revealCards');
  String get startRound => t('startRound');
  String get startRoundTitle => t('startRoundTitle');
  String get taskDescription => t('taskDescription');
  String get cancel => t('cancel');
  String get start => t('start');
  String get revealTitle => t('revealTitle');
  String get revealContent => t('revealContent');
  String get reveal => t('reveal');
  String get results => t('results');
  String get average => t('average');
  String get median => t('median');
  String get min => t('min');
  String get max => t('max');
  String get host => t('host');
  String get player => t('player');
  String get observer => t('observer');
  String get loading => t('loading');
  String get createError => t('createError');
  String get joinError => t('joinError');
  String get invalidUrl => t('invalidUrl');
  String get saveAndRestart => t('saveAndRestart');
  String get settingsSavedRestart => t('settingsSavedRestart');
  String get restart => t('restart');
  String get restartApp => t('restartApp');
  String get restartAppContent => t('restartAppContent');
  String get ok => t('ok');
  String get howToFindIp => t('howToFindIp');
  String get ipStep1 => t('ipStep1');
  String get ipStep2 => t('ipStep2');
  String get ipStep3 => t('ipStep3');
  String get ipStep3Content => t('ipStep3Content');
  String get ipNote => t('ipNote');
  String get urlHistory => t('urlHistory');
  String get close => t('close');
  String get connected => t('connected');
  String get disconnected => t('disconnected');
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ru', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale.languageCode);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}