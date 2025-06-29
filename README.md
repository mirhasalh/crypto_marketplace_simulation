# crypto_marketplace_simulation

A Flutter-based simulation of a cryptocurrency marketplace, designed to mimic real-time trading, asset tracking, and market dynamics. Ideal for educational purposes, prototyping, or exploring crypto trading UX without using real funds.

## Demo

Demo video: [YouTube](https://youtu.be/JkcmSJGByeY)

## Web local database requirements

For the web, download [drift_worker.js](https://github.com/simolus3/drift/releases) and [sqlite3.wasm](https://github.com/simolus3/sqlite3.dart/releases), then place them in the web/ directory to enable local database functionality.

In the end, your web/ directory may look like this:

```plaintext
web/
web/
├── favicon.png
├── index.html
├── manifest.json
├── drift_worker.js
└── sqlite3.wasm
```

## How to run the app

```bash
# Run the app for the web
flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0

# Run the app for the rest of target platforms
flutter run
```

## Library

Libraries used & why:

| Library Name          | Why It Was Used                                                                                                          |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| `drift`               | It's a recently maintained, cross-platform SQLite database that is fully compatible with the latest versions of Flutter. |
| `http`                | To fetch the REST APIs.                                                                                                  |
| `fl_chart`            | Drawing allocations chart.                                                                                               |
| `shared_preferences`  | Keeping simple informations locally.                                                                                     |
| `web_socket_channel`  | Communicate with WebSockets.                                                                                             |
| `scrollview_observer` | Listen for child widgets those are being displayed in the scroll view.                                                   |
| `riverpod`            | Share a states on top of the app for the sake of state management.                                                       |

## Getting started

This project is a Flutter application.

A few resources to get you started:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.