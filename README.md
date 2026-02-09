# PicsumGallery

A demo iOS application that displays a paginated gallery of images from the [Picsum Photos](https://picsum.photos/) API. The project is intended as a concise showcase of modern Swift and SwiftUI practices, architecture, and tooling.

---

## Purpose

This application serves as a technical demonstration: it implements a small but complete feature set (list, detail, settings, caching, localization) using current Apple APIs and conventions. The codebase reflects understanding of:

- Swift 6 concurrency and strict concurrency checking
- SwiftUI lifecycle, state, and navigation
- SwiftData for local persistence
- Structured architecture (MVVM, dependency injection, protocol-based services)
- In-app localization without external catalogs
- Non-blocking user feedback (toasts) and clear separation of concerns

It is suitable as a portfolio piece or as a reference implementation for similar apps.

---

## Technology Stack

| Area | Choice |
|------|--------|
| Language | Swift 6 |
| UI | SwiftUI |
| Persistence | SwiftData (metadata cache), `URLCache` (image cache) |
| Concurrency | `async`/`await`, `Task`, `@MainActor` |
| State | `@Observable` (no `ObservableObject`/`@Published`) |
| Navigation | `NavigationStack` + type-safe `Route` enum |
| Networking | `URLSession`, no third-party HTTP clients |
| Localization | In-code enum (`LocalizedString`) with language selection in settings |

---

## Architecture

- **App entry**: `PicsumGalleryApp` sets up `ModelContainer` (SwiftData) and configures `URLCache` for image caching.
- **Root**: `RouterView` owns a single `NavigationStack`, injects shared services (router, toast store, app settings, error service) via `Environment`, and creates `PhotosViewModel` once with access to `ModelContext`.
- **Features**: Each feature is grouped under `Features/<Name>/` with `Views/`, `ViewModels/`, and `Models/` as needed. Reusable UI and cross-cutting logic live under `Components/` and `Core/`.
- **Data flow**: ViewModels are `@Observable` and receive dependencies (API, cache, error handling, optional localizer) via initializers. Views use `@Environment(\.appSettings)` for theme and language; settings apply immediately and can be reverted on cancel.
- **Network and errors**: `PicsumAPIService` is protocol-based; errors are mapped to `APIServiceError` and handled by a central `ErrorService` that shows toasts and can log.

---

## Main Features

- **Photo list**: Paginated list with pull-to-refresh and “load more”, loading and empty states, and thumbnails with downsampling via `CachedAsyncImage`.
- **Photo detail**: Full-size image and metadata (author, dimensions, aspect ratio).
- **Settings**: Appearance (system/light/dark) and language (English/Russian). Changes apply immediately; leaving without “Done” prompts to discard and revert.
- **Caching**: SwiftData stores photo metadata with TTL; images are cached in `URLCache` and downsampled for list performance.
- **Localization**: All user-facing strings are driven by `LocalizedString` and `AppSettings.languageCode`, with no `.xcstrings` or `.strings` files.

---

## Project Structure

```
PicsumGallery/
  App/                    # Entry point, root view, router
  Core/                   # Navigation, settings, localization
  Data/                   # Network (API, errors), persistence (SwiftData, cache)
  Features/
    Photos/               # List and detail screens, view model, models
    Settings/             # Settings screen
  Components/             # Reusable UI (cached image, toast)
```

Tests and UI tests live in `PicsumGalleryTests/` and `PicsumGalleryUITests/`. Linting and formatting are configured via `.swiftlint.yml` and `.swiftformat`. Branching and workflow are described in `CONTRIBUTING.md`.

---

## Requirements

- Xcode 16+
- iOS 17+ (project may target a higher deployment; check the scheme)
- Swift 6 language mode and strict concurrency enabled for the main app target

---

## How to Run

1. Open `PicsumGallery.xcodeproj` in Xcode.
2. Select the **PicsumGallery** scheme and a simulator or device.
3. Build and run (Cmd+R). The app will request the photo list from the Picsum API and display it; use the list, detail, and settings screens to exercise the flow.

---

# PicsumGallery

Демонстрационное iOS-приложение: галерея изображений с пагинацией, получаемых через API [Picsum Photos](https://picsum.photos/). Проект задуман как компактная демонстрация современных подходов к разработке на Swift и SwiftUI.

---

## Назначение

Приложение служит технической демонстрацией: реализован небольшой, но законченный набор возможностей (список, детальный экран, настройки, кеширование, локализация) с опорой на актуальные API и рекомендации Apple. Код отражает понимание:

- конкуррентности Swift 6 и строгой проверки изоляции;
- жизненного цикла SwiftUI, состояния и навигации;
- SwiftData для локального хранения;
- структурированной архитектуры (MVVM, внедрение зависимостей, сервисы за протоколами);
- внутриприложенной локализации без внешних каталогов строк;
- немодальной обратной связи (тосты) и чёткого разделения ответственности.

Проект подходит как портфолио-пример или как референсная реализация для похожих приложений.

---

## Стек технологий

| Область | Решение |
|--------|---------|
| Язык | Swift 6 |
| UI | SwiftUI |
| Хранение | SwiftData (кеш метаданных), `URLCache` (кеш изображений) |
| Конкуррентность | `async`/`await`, `Task`, `@MainActor` |
| Состояние | `@Observable` (без `ObservableObject`/`@Published`) |
| Навигация | `NavigationStack` и типобезопасный enum `Route` |
| Сеть | `URLSession`, без сторонних HTTP-клиентов |
| Локализация | Enum в коде (`LocalizedString`) и выбор языка в настройках |

---

## Архитектура

- **Точка входа**: `PicsumGalleryApp` настраивает `ModelContainer` (SwiftData) и конфигурирует `URLCache` для кеширования изображений.
- **Корень**: `RouterView` владеет одним `NavigationStack`, прокидывает общие сервисы (роутер, тосты, настройки, обработчик ошибок) через `Environment` и один раз создаёт `PhotosViewModel` с доступом к `ModelContext`.
- **Фичи**: каждая фича сгруппирована в `Features/<Имя>/` с подпапками `Views/`, `ViewModels/`, при необходимости `Models/`. Переиспользуемый UI и общая логика — в `Components/` и `Core/`.
- **Поток данных**: ViewModel’ы помечены `@Observable` и получают зависимости (API, кеш, обработка ошибок, опционально локализатор) через инициализаторы. Экранные view используют `@Environment(\.appSettings)` для темы и языка; настройки применяются сразу, при отмене — откат с подтверждением.
- **Сеть и ошибки**: `PicsumAPIService` описан протоколом; ошибки приводятся к `APIServiceError` и обрабатываются централизованным `ErrorService` с показом тостов и возможностью логирования.

---

## Основные возможности

- **Список фото**: пагинация, pull-to-refresh и подгрузка «ещё», состояния загрузки и пустого списка, превью с даунсэмплингом через `CachedAsyncImage`.
- **Детальный экран**: изображение в полном размере и метаданные (автор, размеры, соотношение сторон).
- **Настройки**: тема (системная/светлая/тёмная) и язык (английский/русский). Изменения применяются сразу; выход без «Готово» предлагает сбросить и откатить настройки.
- **Кеширование**: SwiftData хранит метаданные фото с TTL; изображения кешируются в `URLCache` и масштабируются для списка.
- **Локализация**: все пользовательские строки задаются через `LocalizedString` и `AppSettings.languageCode`, без файлов `.xcstrings` или `.strings`.

---

## Структура проекта

```
PicsumGallery/
  App/                    # Точка входа, корневой экран, роутер
  Core/                   # Навигация, настройки, локализация
  Data/                   # Сеть (API, ошибки), персистенция (SwiftData, кеш)
  Features/
    Photos/               # Список и детальный экран, view model, модели
    Settings/             # Экран настроек
  Components/             # Переиспользуемый UI (кешируемое изображение, тост)
```

Тесты и UI-тесты расположены в `PicsumGalleryTests/` и `PicsumGalleryUITests/`. Линтинг и форматирование заданы в `.swiftlint.yml` и `.swiftformat`. Правила ветвления и workflow описаны в `CONTRIBUTING.md`.

---

## Требования

- Xcode 16+
- iOS 17+ (целевая версия может быть выше — см. настройки схемы)
- Режим языка Swift 6 и включённая строгая проверка конкуррентности для основного таргета

---

## Запуск

1. Открыть `PicsumGallery.xcodeproj` в Xcode.
2. Выбрать схему **PicsumGallery** и симулятор или устройство.
3. Собрать и запустить (Cmd+R). Приложение запросит список фото у Picsum API и отобразит его; список, детальный экран и настройки позволяют проверить весь сценарий.
