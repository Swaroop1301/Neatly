# Neatly App Detailed Documentation

Version: `1.0.0+1`  
Project Root: `C:\Users\SWAROOP\Desktop\OSApp\neatly`  
Primary Platform: Android (Flutter app with Material 3)  
Architecture Style: Layered Flutter app (`UI -> Providers -> Services/DB -> Models`)

---

## 1) App Overview

**Neatly** is an AI-assisted document organizer built with Flutter.  
It accepts document uploads (`PDF`, `DOCX`, `PPTX`), stores them locally, extracts text, classifies them using Anthropic Claude API, auto-assigns folders, and supports full-text search (FTS5).

Core user value:
- Centralized file library for productivity documents.
- Automatic naming, summarization, tagging, and foldering via AI.
- Fast retrieval through indexed search.
- Dark-first aesthetic with glassmorphism UI.

---

## 2) Technology Stack

### Framework and Language
- Flutter
- Dart SDK `>=3.3.0 <4.0.0`

### State and Navigation
- `flutter_riverpod` for state management.
- `go_router` for routing and shell navigation.

### Persistence and Storage
- `sqflite` for mobile database access.
- `sqflite_common_ffi` for desktop fallback.
- `path_provider` + `path` for app document storage.
- `shared_preferences` for user/app settings.
- `flutter_secure_storage` for API key.

### AI and Networking
- `http` for Anthropic API calls.

### Document Parsing
- `syncfusion_flutter_pdf` for PDF text/page extraction.
- `docx_to_text` for DOCX extraction.
- `archive` + `xml` for PPTX parsing (ZIP + slide XML extraction).

### UI/UX Libraries
- `google_fonts` (Plus Jakarta Sans).
- `phosphor_flutter` icons.
- `flutter_animate` for transitions/entrance effects.
- `shimmer` for pending loading placeholders.

---

## 3) App Architecture

### Layered Organization

1. **UI Layer (`lib/ui`)**
- Screens, widgets, shell navigation, reusable components.

2. **State Layer (`lib/providers`)**
- Riverpod notifiers and providers for documents, folders, search, settings, AI queue.

3. **Data Layer (`lib/data`)**
- Local SQLite DB operations.
- File operations.
- Parsing service for documents.
- AI service for classification.

4. **Domain Layer (`lib/domain/models`)**
- Strongly typed models (`DocumentModel`, `FolderModel`, `AiResult`).

### Runtime Pipeline (Upload to Organized Document)

1. User uploads file from FAB or empty-state CTA.
2. File is copied to app storage (`neatly_files`).
3. Document metadata is inserted into SQLite (`ai_status = pending`).
4. Document ID is queued in AI queue provider.
5. Parser extracts content from file.
6. AI service sends prompt to Claude and parses JSON response.
7. Folder is fetched/created.
8. Document is updated with AI result (name, summary, tags, folder, status).
9. Document content is indexed into FTS table.
10. UI reflects updated status and searchable metadata.

---

## 4) Routing and Navigation

Router file: `lib/router.dart`

### Route map
- `/onboarding` -> `OnboardingScreen`
- Shell routes via `MainShell`:
  - `/home` -> `HomeScreen`
  - `/library` -> `LibraryScreen`
  - `/search` -> `SearchScreen`
  - `/settings` -> `SettingsScreen`
- `/document/:docId` -> `DocumentDetailScreen`

### Route behavior
- App starts at `/onboarding`.
- Redirect logic checks `isFirstLaunch` from shared preferences.
- If first launch, user is forced to onboarding until completion.
- Bottom nav in shell controls Home/Library/Search/Settings.

---

## 5) Visual Design System (Color + Aesthetic)

Neatly uses a **dark-first**, soft-glass, contrast-balanced visual style with subtle accent glows and rounded surfaces.

### 5.1 Core Palette

#### Dark Mode
- `darkBackground`: `#0A0A0F`
- `darkBackgroundSecondary`: `#111118`
- `darkBackgroundTertiary`: `#1A1A24`
- `darkTextPrimary`: `#F2F2F7`
- `darkTextSecondary`: `#8E8E9A`
- `darkTextTertiary`: `#48484F`

#### Light Mode
- `lightBackground`: `#F2F2F7`
- `lightBackgroundSecondary`: `#FFFFFF`
- `lightBackgroundTertiary`: `#F2F2F7`
- `lightTextPrimary`: `#1C1C1E`
- `lightTextSecondary`: `#6C6C70`
- `lightTextTertiary`: `#AEAEB2`

#### Accent and Semantic
- Default accent (dark): `#7C6FE0`
- Default accent (light): `#5E4FD1`
- Success: `#34C759`
- Warning: `#FF9F0A`
- Destructive: `#FF453A` (light variant `#FF3B30`)

### 5.2 Folder Color Palette

- Violet: `#7C6FE0`
- Rose: `#E06F9B`
- Amber: `#E09A3F`
- Emerald: `#3FB87A`
- Sky: `#3F8FE0`
- Coral: `#E0613F`
- Slate: `#6F8EA0`
- Plum: `#9B6FE0`

### 5.3 File Type Colors

- PDF: `#E0613F`
- DOC/DOCX: `#3F8FE0`
- PPT/PPTX: `#E09A3F`

### 5.4 Typography

Font family: **Plus Jakarta Sans** (`google_fonts`).

Token examples:
- `displayLarge` 34 / 700
- `displayMedium` 28 / 700
- `titleLarge` 22 / 600
- `bodyMedium` 15 / 400
- `caption` 11 / 400

### 5.5 Layout Tokens

- Spacing uses strict 4dp grid.
- Key values:
  - `sm=8`, `md=12`, `lg=16`, `screenPadding=20`, `section=32`
- Rounded corners:
  - `sm=8`, `md=12`, `lg=16`, `xl=20`, `pill=100`

### 5.6 Motion and Interaction

- Entrance animations: fade + slide (`flutter_animate`).
- FAB pulse/breathing loop.
- AI status shimmer effect.
- Document cards support:
  - touch scale on tap,
  - swipe-left to delete action.
- Haptic feedback integrated in nav/select/delete gestures.

### 5.7 Visual Language Summary

- Frosted glass containers (`BackdropFilter` blur).
- Soft shadows and low-opacity borders.
- Accent-glow highlights on active controls.
- Card-first information layout for scanability.

---

## 6) Feature-by-Feature Breakdown

## 6.1 Onboarding
File: `lib/ui/screens/onboarding/onboarding_screen.dart`

- Single CTA (`Get Started`).
- Sets `isFirstLaunch=false` in shared preferences.
- Redirects to `/home`.

## 6.2 Home Screen
File: `lib/ui/screens/home/home_screen.dart`

- Greeting based on current time.
- Summary text: number of AI-sorted files.
- AI queue status pill when processing pending items.
- Quick stats row:
  - total files,
  - total folders,
  - files uploaded in last 7 days.
- Horizontal folder preview.
- Recent documents list using `DocumentCard`.
- Empty state with upload CTA if no documents.
- Tapping document opens `/document/:id`.

## 6.3 Document Card (Core UI Component)
File: `lib/ui/screens/home/widgets/document_card.dart`

- States:
  - pending: shimmer skeleton,
  - processing: progress indicator,
  - failed: warning/red accents,
  - done: normal content with metadata.
- Displays:
  - display name,
  - AI summary (if present),
  - folder chip color/name,
  - file size,
  - relative timestamp.
- Supports:
  - swipe-to-delete gesture,
  - favorite badge visualization (star).

## 6.4 Library Screen
File: `lib/ui/screens/library/library_screen.dart`

- Folder grid view.
- Includes special **All Files** card.
- Folder cards show icon, count, and color.
- Empty-state CTA to upload first document.
- Tap folder -> `FolderDetailScreen`.

## 6.5 Folder Detail Screen
File: `lib/ui/screens/library/folder_detail_screen.dart`

- Hero-style folder header with radial glow.
- File-type filters: `All`, `PDF`, `DOCX`, `PPTX`.
- Filtered document list.
- Empty state for no matching docs.

## 6.6 Search Screen
File: `lib/ui/screens/search/search_screen.dart`

- Debounced search (250ms).
- Full-text query against FTS index.
- Recent searches list and management.
- Search results reuse `DocumentCard`.
- Empty states for no recents / no results.

## 6.7 Settings Screen
File: `lib/ui/screens/settings/settings_screen.dart`

- Currently placeholder UI (`Settings Screen` text).
- Backend settings logic exists in `settings_provider.dart` but UI controls are not yet wired.

## 6.8 Document Detail Screen
File: `lib/ui/screens/document_detail/document_detail_screen.dart`

- Route-aware placeholder screen displaying `docId`.
- Detailed metadata/content view not yet implemented.

## 6.9 Main Shell and Navigation
Files:
- `lib/ui/shell/main_shell.dart`
- `lib/ui/shell/widgets/glass_nav_bar.dart`
- `lib/ui/shell/widgets/upload_fab.dart`

- Floating glass bottom nav with four tabs.
- Floating animated upload FAB.
- Edge-to-edge system UI.

---

## 7) Data Model and Database Details

Database file: `lib/data/database/app_database.dart`

SQLite file path: `<app_documents>/neatly.db`

### Tables

#### 1. `folders`
- `id` (PK, autoincrement)
- `name` (unique, required)
- `color_name`
- `icon_name`
- `is_ai_generated`
- `created_at` (epoch ms)
- `sort_order`

#### 2. `documents`
- `id` (PK)
- `folder_id` (nullable FK to folders)
- `original_name`
- `ai_name`
- `display_name`
- `file_path`
- `file_type`
- `file_size_bytes`
- `page_count`
- `ai_summary`
- `ai_tags` (JSON string)
- `ai_status` (`pending|processing|done|failed`)
- `is_favourite` (0/1)
- `last_opened_at`
- `uploaded_at`
- `updated_at`

#### 3. `document_fts` (FTS5 virtual table)
- `doc_id` (unindexed)
- `display_name`
- `ai_summary`
- `full_text_content`
- `ai_tags`

#### 4. `recent_searches`
- `id` (PK)
- `query`
- `searched_at`

### Search Implementation

- FTS query pattern: `query*` prefix search.
- Search returns ranked doc IDs from `document_fts`.
- IDs are then resolved to document records with folder joins.

### Duplicate Handling

- Duplicate check logic exists (`original_name` + `file_size_bytes`).
- If setting `autoDeleteDuplicates` is enabled, duplicates are skipped during upload.

---

## 8) Services and Business Logic

## 8.1 File Service
File: `lib/data/services/file_service.dart`

- Creates/uses app storage directory: `neatly_files`.
- Sanitizes copied filenames and prefixes timestamp.
- Deletes stored files when documents are deleted.
- Provides file type normalization and size formatting helpers.

## 8.2 Document Parser Service
File: `lib/data/services/document_parser_service.dart`

- PDF:
  - Extracts text page-by-page.
  - Reads page count.
- DOCX:
  - Converts binary to plain text.
- PPTX:
  - Unzips package.
  - Reads `ppt/slides/slide*.xml`.
  - Extracts `<a:t>` text nodes.
  - De-duplicates repeated text snippets.
- Trims extracted content to `maxTextExtractionLength`.

## 8.3 AI Service
File: `lib/data/services/ai_service.dart`

- Stores Anthropic API key securely (`flutter_secure_storage`).
- Validates API key with lightweight test call.
- Classification API call includes:
  - strict JSON output request,
  - suggested name,
  - folder name,
  - summary,
  - tags,
  - confidence.
- Handles:
  - retries with exponential backoff,
  - rate limit (`429`),
  - invalid key (`401`),
  - network exceptions.

---

## 9) State Management (Providers)

### `databaseProvider`
- Exposes singleton `AppDatabase`.

### `documentsProvider` (`DocumentsNotifier`)
- Loads documents.
- Handles picker upload flow.
- Handles single-path upload.
- Deletes docs and underlying files.
- Toggles favorites.
- Renames/moves docs.
- Retries AI processing.

### `foldersProvider` (`FoldersNotifier`)
- Loads folders.
- Creates manual folder.
- Auto-creates missing AI folder with color cycling.

### `searchProvider` (`SearchNotifier`)
- Debounced text query execution.
- Recent search persistence and deletion.

### `settingsProvider` (`SettingsNotifier`)
- Theme mode and accent index.
- Auto-sort toggle.
- AI summary visibility toggle.
- Duplicate auto-delete toggle.
- Default sort order and grid view state.
- First launch status.

### `aiQueueProvider` (`AiQueueNotifier`)
- Maintains queue of document IDs.
- Sequentially processes docs.
- Updates AI status transitions.
- Performs extraction + classification + foldering + FTS indexing.
- Captures latest queue error.

---

## 10) File and Folder Structure

Complete project source structure (`lib` + `android`):

```text
android/
  app/
    build.gradle.kts
    src/
      debug/AndroidManifest.xml
      main/
        AndroidManifest.xml
        java/io/flutter/plugins/GeneratedPluginRegistrant.java
        kotlin/com/neatly/neatly/MainActivity.kt
        res/
          drawable/launch_background.xml
          drawable-v21/launch_background.xml
          mipmap-hdpi/ic_launcher.png
          mipmap-mdpi/ic_launcher.png
          mipmap-xhdpi/ic_launcher.png
          mipmap-xxhdpi/ic_launcher.png
          mipmap-xxxhdpi/ic_launcher.png
          values/styles.xml
          values-night/styles.xml
      profile/AndroidManifest.xml
  build.gradle.kts
  gradle.properties
  gradle/wrapper/
    gradle-wrapper.jar
    gradle-wrapper.properties
  gradlew
  gradlew.bat
  local.properties
  neatly_android.iml
  settings.gradle.kts

lib/
  app.dart
  main.dart
  router.dart

  core/
    constants.dart
    extensions/
      datetime_extensions.dart
      int_extensions.dart
      string_extensions.dart
    theme/
      app_colors.dart
      app_radius.dart
      app_shadows.dart
      app_spacing.dart
      app_text_styles.dart
      app_theme.dart

  data/
    database/
      app_database.dart
    services/
      ai_service.dart
      document_parser_service.dart
      file_service.dart

  domain/
    models/
      ai_result.dart
      document.dart
      folder.dart

  providers/
    ai_queue_provider.dart
    database_provider.dart
    documents_provider.dart
    folders_provider.dart
    search_provider.dart
    settings_provider.dart

  ui/
    screens/
      document_detail/
        document_detail_screen.dart
      home/
        home_screen.dart
        widgets/
          ai_status_pill.dart
          document_card.dart
          quick_stat_card.dart
      library/
        folder_detail_screen.dart
        library_screen.dart
      onboarding/
        onboarding_screen.dart
      search/
        search_screen.dart
      settings/
        settings_screen.dart
    shared/
      empty_state.dart
      file_type_icon.dart
      glass_container.dart
    shell/
      main_shell.dart
      widgets/
        glass_nav_bar.dart
        upload_fab.dart
```

---

## 11) Android Packaging and Build Profile

### Android app configuration
- Namespace: `com.neatly.neatly`
- Application ID: `com.neatly.neatly`
- Kotlin/Java target: `11`
- Gradle plugin: Android `8.7.3`, Kotlin `2.1.0`
- NDK configured: `27.0.12077973`

### Current release signing state
- Release build type currently uses **debug signing config**.
- This is acceptable for internal test APK generation.
- For Play Store distribution, a dedicated release keystore must be configured.

---

## 12) Current Functional Status Summary

### Implemented and usable
- Onboarding gate.
- File picker uploads.
- Local file storage and metadata persistence.
- AI queue processing and status tracking.
- Automatic folder creation from AI result.
- Folder/document listings.
- Search with FTS and recents.
- Dark/light theme engine and accent system.
- Android APK build pipeline.

### Partially implemented or placeholder
- Settings screen UI (provider logic exists, UI not wired).
- Document detail UI (route exists, placeholder content).
- Library sort button (UI present, logic not implemented).
- “View all”/“See all” labels in some places are visual only.

---

## 13) Design and Product Identity Summary

Neatly’s design identity is:
- **Dark-first** and productivity-oriented.
- **Card-centric** for scan speed and content hierarchy.
- **Glass + blur** elements for modern depth.
- **Accent-driven categorization** (folder colors, type chips, status states).
- **Low-friction interactions** (haptics, smooth animations, swipe gestures).

This gives the app a premium, modern utility feel while keeping interaction patterns simple and clear.

---

## 14) Suggested Next Enhancements

1. Build complete `SettingsScreen` to expose all existing settings provider toggles.
2. Replace `DocumentDetailScreen` placeholder with full metadata/preview panel.
3. Add optimistic and inline error UI for uploads and AI failures.
4. Add explicit duplicate handling dialog (skip/replace/keep both) when auto-delete is off.
5. Add tests for database methods and AI queue state transitions.
6. Add proper release signing config + CI build script for production APK/AAB.
7. Improve folder route to resolve real folder model from DB by `folderId`.

---

## 15) Quick Orientation for New Developers

If you are onboarding into this codebase:

1. Start from `lib/main.dart`, `lib/app.dart`, and `lib/router.dart`.
2. Read providers in this order:
   - `documents_provider.dart`
   - `ai_queue_provider.dart`
   - `folders_provider.dart`
   - `search_provider.dart`
   - `settings_provider.dart`
3. Then read data services:
   - `app_database.dart`
   - `document_parser_service.dart`
   - `ai_service.dart`
4. Finally inspect UI shell and Home/Library/Search screens for behavior mapping.

This sequence gives fastest understanding of app behavior end-to-end.

