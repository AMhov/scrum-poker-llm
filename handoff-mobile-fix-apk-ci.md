# Handoff: Scrum Poker Mobile — Fix APK Installation & CI

**От:** Текущая сессия  
**Для:** Следующий агент  
**Дата:** 2026-08-24  
**Фокус:** Исправление установки APK и CI/CD

---

## Контекст

Мобильное приложение (Flutter) собрано, но APK не устанавливается на телефон. CI/CD пайплайн падает.

---

## Что сделано

### 1. Исправление namespace (критично)

**Проблема:** `com.example.scrum_poker_mobile` — зарезервированный namespace, Android может блокировать установку.

**Исправления:**

- `android/app/build.gradle.kts`:
  - `namespace = "com.example.scrum_poker_mobile"` → `namespace = "com.scrumpoker.mobile"`
  - `applicationId = "com.example.scrum_poker_mobile"` → `applicationId = "com.scrumpoker.mobile"`
  - Убран блок `splits { abi { isEnable = false } }` (конфликтовал с Flutter Gradle Plugin)

- `android/app/src/main/kotlin/com/example/scrum_poker_mobile/MainActivity.kt`:
  - Перемещён в `android/app/src/main/kotlin/com/scrum_poker/mobile/MainActivity.kt`
  - Package изменён на `com.scrumpoker.mobile`

### 2. Исправление CI/CD

**Проблема:** `--split-per-abi=false` не принимает значение в `flutter build apk`.

**Исправление:** Убран флаг `--split-per-abi=false` из `.github/workflows/build-apk.yml`.

### 3. Текущее состояние файлов

**`android/app/build.gradle.kts`:**
```kotlin
plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.scrumpoker.mobile"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.scrumpoker.mobile"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
```

**`.github/workflows/build-apk.yml`:**
```yaml
name: Build APK

on:
  push:
    branches: [am_mobile, main]
  pull_request:
    branches: [am_mobile, main]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.47.1'
          channel: 'stable'

      - name: Build APK
        working-directory: mobile
        run: |
          flutter pub get
          flutter build apk --release

      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: app-release-apk
          path: mobile/build/app/outputs/flutter-apk/app-release.apk
          retention-days: 30
```

---

## Текущая проблема

### CI падает с ошибкой:

```
FAILURE: Build failed with an exception.

* What went wrong:
Error resolving plugin [id: 'dev.flutter.flutter-plugin-loader', version: '1.0.0']
> A problem occurred configuring project ':gradle'.
   > Could not resolve all artifacts for configuration 'classpath'.
      > Could not resolve org.jetbrains.kotlin:kotlin-stdlib:2.2.21.
        Required by:
            buildscript of project ':gradle'
         > Repository Gradle Central Plugin Repository is disabled due to earlier error below:
            > Could not resolve org.jetbrains.kotlin:kotlin-gradle-plugins-bom:2.2.20.
               > Could not get resource 'https://plugins.gradle.org/m2/org/jetbrains/kotlin/kotlin-gradle-plugins-bom/2.2.20/kotlin-gradle-plugins-bom-2.2.20.pom'.
                  > Could not GET 'https://repo.maven.apache.org/maven2/org/jetbrains/kotlin/kotlin-gradle-plugins-bom/2.2.20/kotlin-gradle-plugins-bom-2.2.20.pom'. Received status code 429 from server: Too Many Requests
```

**Причина:** GitHub Actions runner не может скачать зависимости из Maven/Gradle Central Plugin Repository. Сервер возвращает `429 Too Many Requests` (перегрузка).

**Это временная проблема CI**, не баг в коде.

---

## Что нужно сделать

### Приоритет 1: Исправить CI

1. **Перезапустить workflow** вручную из GitHub Actions — часто помогает при временных сетевых ошибках.
2. **Добавить retry** в `build-apk.yml` для автоматического повторения при сетевых ошибках:
   ```yaml
   - name: Build APK
     working-directory: mobile
     run: |
       flutter pub get
       flutter build apk --release
     env:
       GRADLE_OPTS: -Dorg.gradle.daemon=false
   ```
3. **Проверить** `settings.gradle.kts` — возможно, нужно добавить Maven репозитории явно.

### Приоритет 2: Проверить установку APK

После успешной сборки CI:
1. Скачать `app-release-apk` из артефактов
2. Установить на телефон
3. Если ошибка — посмотреть логи через `adb install -r app-release.apk`

### Приоритет 3: Опциональные улучшения

- Добавить unit-тесты для BLoC и сервисов
- Добавить iOS deep links (Info.plist)
- Добавить дополнительные языки (DE, FR, ES)

---

## Архитектура мобильного приложения

```
mobile/
├── lib/
│   ├── main.dart                  # Точка входа, MultiBlocProvider
│   ├── app_router.dart            # go_router + deep links
│   ├── l10n/
│   │   └── app_localizations.dart # RU/EN локализация
│   ├── blocs/
│   │   └── app_bloc.dart          # Единый BLoC (7 событий, 6 слушателей)
│   ├── services/
│   │   ├── api_service.dart       # REST API (6 методов)
│   │   ├── socket_service.dart    # WebSocket (6 event-стримов)
│   │   └── session_service.dart   # SharedPreferences
│   ├── models/
│   │   ├── role.dart              # enum: host, player, observer
│   │   ├── player.dart            # Data class + JSON
│   │   ├── room.dart              # Data class + copyWith
│   │   ├── round.dart             # Data class + copyWith
│   │   └── vote.dart              # Data class + JSON
│   ├── screens/
│   │   ├── home_screen.dart       # Создание + вступление
│   │   ├── room_screen.dart       # Комната, карты, FAB
│   │   ├── settings_screen.dart   # Тема + URL
│   │   └── about_screen.dart      # Версия, GitHub
│   ├── widgets/
│   │   ├── player_list.dart       # Игроки + статус
│   │   ├── vote_cards.dart        # Колода Фибоначчи + анимации
│   │   └── reveal_panel.dart      # Результаты + статистика
│   └── theme/
│       └── app_theme.dart         # Светлая/тёмная тема
├── android/
│   └── app/
│       ├── build.gradle.kts       # namespace: com.scrumpoker.mobile
│       ├── src/main/AndroidManifest.xml
│       └── src/main/kotlin/com/scrum_poker/mobile/MainActivity.kt
└── pubspec.yaml
```

---

## Ключевые решения

| Решение | Выбор |
|---------|-------|
| Фреймворк | Flutter (Dart) |
| Управление состоянием | BLoC (единый AppBloc) |
| Навигация | go_router (named routes + deep links) |
| WebSocket | socket_io_client |
| HTTP | http |
| Данные | Ручные классы |
| UI | Material 3 |
| Локализация | Ручной словарь (RU/EN) |
| Сессия | SharedPreferences |
| Подпись | Debug-ключ для release (тестовая установка) |
| Пакет | com.scrumpoker.mobile |

---

## Связанные файлы

- **Веб-версия:** `frontend/` — React + Vite
- **Бэкенд:** `backend/` — Flask + SQLAlchemy
- **Документация проекта:** `KODA.md`
- **Предыдущий handoff:** `handoff-mobile.md`
- **Финальный handoff:** `handoff-mobile-complete.md`

---

## Suggested Skills

- **[tdd](./skills/tdd/SKILL.md)** — Для написания тестов
- **[to-spec](./skills/to-spec/SKILL.md)** — Для создания спецификаций доработок
- **[implement](./skills/implement/SKILL.md)** — Для реализации конкретных фич
- **[grilling](./skills/grilling/SKILL.md)** — Для принятия архитектурных решений

---

## Примечания

- Приложение использует HTTP (не HTTPS) для локальной разработки — нужен `usesCleartextTraffic`
- Бэкенд по умолчанию: `http://localhost:5000`
- Числа на картах: Фибоначчи `[0, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89]`
- Деплой: Firebase App Distribution (не Play Store)
- CI падает из-за 429 от Maven/Gradle сервера — временная проблема
