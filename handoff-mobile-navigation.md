# Handoff: Scrum Poker Mobile — Навигация и подключение к бэкенду

**От:** Текущая сессия  
**Для:** Следующий агент  
**Дата:** 2026-08-25  
**Фокус:** BottomNavigationBar + настройка подключения к бэкенду

---

## Что сделано в этой сессии

### 1. Исправление CI/CD для сборки APK

**Проблема:** CI падал с ошибкой NDK/compileSdk несовместимости.

**Исправления:**

| Файл | Изменение |
|------|-----------|
| `mobile/android/app/build.gradle.kts` | `compileSdk` 35→36, `ndkVersion` 27→28.2.13676358, `targetSdk` 35→36 |
| `.github/workflows/build-apk.yml` | Добавлены `GRADLE_OPTS` для предотвращения 429 ошибок |

**Коммиты:**
- `ee5e620` — upgrade compileSdk/NDK
- `2ffdce5` — hardcode SDK versions + Gradle limits

### 2. Добавление BottomNavigationBar

**Проблема:** В приложении не было навигационной панели — три вкладки были в router, но пользователь их не видел.

**Решение:** Переписан `mobile/lib/main.dart`:
- Убран `app_router.dart` (интегрировано в main)
- Добавлен `ShellRoute` с `MainNavigationScreen`
- `BottomNavigationBar` с 3 вкладками: Главная, Комната, Настройки
- Умная навигация: вкладка "Комната" переходит в последнюю открытую комнату или на главную, если комнаты нет
- `didUpdateWidget` синхронизирует индекс вкладки с текущим URI

**Коммит:** `b4673eb`

---

## Текущее состояние

### Что работает
- ✅ APK собирается на CI (после исправления SDK/NDK)
- ✅ APK устанавливается на телефон (Play Protect отключён)
- ✅ BottomNavigationBar с 3 вкладками
- ✅ Локализация RU/EN
- ✅ Базовая структура приложения

### Что НЕ работает
- ❌ **Бэкенд не подключён** — по умолчанию `http://localhost:5000`, на телефоне это сам телефон
- ❌ **Нет кнопок "Создать комнату" / "Вступить"** — HomeScreen показывает формы, но они не работают без бэкенда
- ❌ **RoomScreen пустой** — нет комнаты, нет данных
- ❌ **SettingsScreen не сохраняет** — URL сохраняется, но нужен перезапуск приложения

### Что нужно сделать

#### Приоритет 1: Подключение к бэкенду

1. **Узнать IP компьютера** с бэкендом:
   ```bash
   hostname -I  # или ip addr show | grep inet
   ```

2. **Настроить на телефоне:**
   - Вкладка "Настройки" → URL бэкенда: `http://192.168.X.X:5000`
   - Сохранить → **перезапустить приложение** (URL берётся при старте)

3. **Проверить:**
   - Бэкенд и телефон в одной Wi-Fi сети
   - Firewall на компьютере пропускает порт 5000

#### Приоритет 2: Пересборка APK

После коммита `b4673eb` CI должен собрать новый APK. Скачать из артефактов и установить.

#### Приоритет 3: Тестирование

- Создать комнату → проверить что данные уходят на бэкенд
- Вступить в комнату → проверить что игрок появляется
- Голосование → проверить что голос фиксируется
- Раскрытие карт → проверить что результаты видны

---

## Архитектура изменений

### main.dart (переписан)

```
main()
  ├── SharedPreferences.getInstance()
  ├── ApiService(baseUrl)
  ├── SocketService(baseUrl)
  ├── SessionService()
  ├── GoRouter(
  │   ├── ShellRoute(
  │   │   ├── MainNavigationScreen(BottomNavigationBar)
  │   │   │   ├── HomeScreen (/)
  │   │   │   ├── RoomScreen (/room/:roomId)
  │   │   │   └── SettingsScreen (/settings)
  │   │   └── AboutScreen (/about) — вне ShellRoute
  │   └── redirect: deep links
  │   )
  └── MultiProvider(
      ├── ApiService
      ├── SocketService
      ├── SessionService
      └── AppBloc
      )
```

### Ключевые изменения

| Было | Стало |
|------|-------|
| `app_router.dart` — отдельный файл | Router в `main.dart` |
| `MaterialApp.router` с `AppRouter.router` | `MaterialApp.router` с локальным router |
| Нет навигации | `ShellRoute` + `BottomNavigationBar` |
| `AppRouter._redirect` | `_redirect` в main.dart |

---

## Известные проблемы

### 1. didUpdateWidget не синхронизирует индекс вкладки

`didUpdateWidget` использует `ModalRoute.of(context)?.settings.arguments` — это может не сработать при навигации через `GoRouter`. Нужно проверить и, если нужно, заменить на `GoRouterState.of(context)` или `context.routerDelegate.currentUri`.

### 2. URL бэкенда не обновляется без перезапуска

`ApiService` создаётся в `main()` один раз. Если пользователь меняет URL в настройках, нужен перезапуск приложения. Можно улучшить, добавив `BlocListener` на SettingsScreen, который перезапускает приложение или пересоздаёт сервисы.

### 3. Вкладка "Комната" без активной комнаты

Если комнаты нет, вкладка "Комната" переходит на главную. Можно добавить подсказку или пустой state.

---

## Связанные файлы

- **Веб-версия:** `frontend/` — React + Vite
- **Бэкенд:** `backend/` — Flask + SQLAlchemy
- **Документация проекта:** `KODA.md`
- **Предыдущие handoff:**
  - `handoff-mobile.md` — первоначальная разработка
  - `handoff-mobile-complete.md` — завершение разработки
  - `handoff-mobile-fix-apk-ci.md` — исправление APK и CI

---

## Suggested Skills

- **[tdd](./skills/tdd/SKILL.md)** — Для написания тестов
- **[to-spec](./skills/to-spec/SKILL.md)** — Для создания спецификаций доработок
- **[implement](./skills/implement/SKILL.md)** — Для реализации конкретных фич
- **[grilling](./skills/grilling/SKILL.md)** — Для принятия архитектурных решений

---

## Примечания

- Приложение использует HTTP (не HTTPS) — нужен `usesCleartextTraffic` (уже настроен)
- Бэкенд по умолчанию: `http://localhost:5000`
- Числа на картах: Фибоначчи `[0, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89]`
- Деплой: Firebase App Distribution (не Play Store)
- Package: `com.scrumpoker.mobile`
- minSdk: 24, compileSdk: 36, targetSdk: 36
