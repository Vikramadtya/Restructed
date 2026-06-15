# Restructed: Core Architecture Manual

This document details the definitive architecture for the Restructed macOS application following the shift to a strict Component-Based Architecture utilizing Java-style conventions (no `_` prefixes for private fields) and a dedicated root proxy daemon.

---

## 1. Component Separation (`/ui`, `/backend`, `/daemon`)

The project is strictly divided into three primary layers:

### The UI Domain (`/ui`)
Powered by Flutter and Riverpod. 
* **Rule**: UI code *never* directly instantiates backend logic. It observes state and triggers actions exclusively through `app_providers.dart`.
* **Structure**: Organized by features (`/rules`, `/categories`, `/dashboard`, `/analytics`). Each folder contains the Riverpod state notifiers and Flutter Widgets specific to that domain.

### The Backend Domain (`/backend`)
Contains the core business logic, the Drift database implementation, and the communication bridges.
* **Core**: Handles Dependency Injection (`injection.dart`) using `get_it`, and the Drift SQLite Database setup (`database.dart`).
* **Repositories**: Each domain (Rules, Categories, Analytics) possesses its own Models and Repositories.
* **Daemon Client**: Handles the two-way TCP/UDP communication with the OS root daemon.

### The Root Daemon (`/daemon`)
A standalone Dart executable (`proxy_daemon.dart`) compiled and shipped inside the macOS app bundle. It runs completely statelessly as the `root` user.

---

## 2. Inter-Process Communication (Daemon Sync)

Because the Flutter application runs in a sandboxed user space, it cannot natively edit `/etc/hosts` or `pkill` other applications.

To solve this, we launch the **Proxy Daemon** via `osascript` on startup (asking the user for their password once). The daemon binds to local ports and waits for instructions.

### The Control Channel (TCP 8193)
* The `DaemonConnectionManager` in the frontend establishes a persistent, secure TCP connection to `127.0.0.1:8193`.
* A secure token generated at startup ensures malicious apps cannot hijack the daemon.
* When the user toggles a rule in the UI, the frontend serializes the entire active blocklist and sends it over TCP.
* The `DaemonEnforcer` immediately modifies `/etc/hosts` and kills any blocked desktop apps using `pkill`.

### The Analytics Stream (UDP 8192)
* The `TrafficInterceptor` inside the daemon binds to local ports 80 and 443.
* When `/etc/hosts` sinkholes a blocked website like `reddit.com` to `127.0.0.1`, the browser connects to the `TrafficInterceptor`.
* The interceptor reads the raw Server Name Indication (SNI) string from the TLS handshake, drops the connection, and fires a lightning-fast UDP datagram containing the blocked domain to the frontend on port `8192`.
* The frontend's `DaemonService` catches this UDP packet, logs the attempt in the SQLite database, and increments the user's dashboard charts.

---

## 3. The Drift Database

We migrated from Isar to **Drift (SQLite)** for better stability and explicit relational mapping.

### Schema Design
* **`Categories`**: Holds customizable categories (e.g., "Social Media", "Work").
* **`BlockRules`**: Holds individual domains or apps, linked to a Category via a foreign key constraint. Contains an active toggle flag.
* **`BlockAttempts`**: A high-throughput analytics table logging every single intercepted packet. Links to a `BlockRule` and stores a UNIX timestamp.

### Performance Considerations
To ensure the UDP listener doesn't drop packets during heavy traffic, we utilize Drift's background isolates (`NativeDatabase.createInBackground`). The database operations are fully asynchronous and batched where necessary to prevent blocking the Flutter UI thread.
