# Restructed 🎯

Restructed is a premium macOS productivity and website/app blocking application designed to help you regain your focus. Unlike simple browser extensions, Restructed operates at the system level via a highly secure, stateless root daemon proxy, making it incredibly difficult to bypass during active focus sessions.

## 🚀 Features

- **System-Level Blocking**: Modifies `/etc/hosts` and monitors macOS processes to enforce blocks.
- **Dynamic Analytics**: Real-time UDP-based packet interception to log blocked attempts instantly without polling.
- **Glassmorphic UI**: A stunning, custom-built Material design with frosted glass aesthetics and fluid animations.
- **Focus Modes**: Supports duration-based blocks (Countdown Timer) and recurring schedules (e.g., Weekdays 9 AM - 5 PM).
- **Strict Mode**: The "Nuclear Option" requiring paragraph transcription to disable active blocks.

## 🏗️ Architecture

Restructed uses a strictly separated, three-tier architecture:

1.  **Frontend (`/ui`)**: Flutter + Riverpod. Purely reactive UI layer handling no direct logic.
2.  **Backend (`/backend`)**: Business logic, Drift SQLite Database, and Dependency Injection.
3.  **Daemon (`/daemon`)**: A stateless Dart executable that runs with root privileges. It listens on TCP (Control) and UDP (Analytics) ports.

Read the full [Architecture Design Document](ARCHITECTURE_DESIGN_DOC.md) for more details.

## 💻 Tech Stack

- **Framework**: Flutter (macOS Desktop)
- **State Management**: Riverpod (`flutter_riverpod`)
- **Database**: Drift (SQLite)
- **Dependency Injection**: GetIt (`get_it`)
- **Logging & Crash Reporting**: Talker & Sentry (`sentry_flutter`)
- **CI/CD**: GitHub Actions (`release_pipeline.yml` -> builds DMG)

## 🛠️ Development Setup

1. **Prerequisites**: Ensure you have the Flutter SDK (stable channel) installed on macOS.
2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```
3. **Run Code Generation** (if you modify Drift tables or Riverpod providers):
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
4. **Run the App**:
   ```bash
   flutter run -d macos
   ```

## 📦 Building for Release

The project includes a GitHub Action to automatically build a `.dmg` file for distribution on every push to `main` or upon tagging a release.

To manually build a `.dmg` locally:
```bash
flutter build macos --release
brew install create-dmg
create-dmg \
  --volname "Restructed Installer" \
  --window-pos 200 120 \
  --window-size 600 400 \
  --icon-size 100 \
  --icon "Restructed.app" 175 190 \
  --hide-extension "Restructed.app" \
  --app-drop-link 425 190 \
  "Restructed.dmg" \
  "build/macos/Build/Products/Release/restructed.app"
```

## 🔒 Security & Privacy

Restructed runs entirely locally. Your blocklist and analytics data never leave your machine. The root proxy daemon is stateless, meaning it only applies rules commanded by the sandboxed frontend client through an authenticated, local TCP connection.
