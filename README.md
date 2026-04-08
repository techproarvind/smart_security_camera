# SmartCam — Smart Security Camera

A Flutter app that turns any two phones into a security camera system using WebRTC peer-to-peer live streaming.

---

## Features

- **Live Streaming** — Real-time peer-to-peer video via WebRTC (no monthly fee)
- **Role Selection** — One phone acts as the camera, another as the viewer
- **Camera Controls** — Flip camera, mute/unmute mic, toggle video on broadcaster side
- **Viewer Controls** — Mirror video flip, audio mute on viewer side
- **Dashboard** — Camera list, alerts, analytics with people occupancy tracking
- **People Counter** — Track how many people are in each camera zone
- **Alerts** — Motion, intrusion, entry/exit alerts with unread badge
- **Settings** — User profile, notifications, security, storage preferences
- **Animated Splash Screen** — Pulse rings, scan line, rotating dashed ring, corner brackets
- **Custom App Icon** — Security camera themed icon for both Android and iOS

---

## App Flow

```
Splash → Login → Role Selection → Dashboard
                                      ├── Cameras Tab
                                      ├── Alerts Tab
                                      ├── Analytics Tab
                                      └── FAB → Broadcast (camera) / Live View (viewer)
```

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x (Dart) |
| State Management | Provider |
| Live Streaming | WebRTC (`flutter_webrtc`) |
| Signaling | WebSocket (`web_socket_channel`) |
| Permissions | `permission_handler` |
| Icons | `flutter_launcher_icons` |

---

## Project Structure

```
lib/
├── config/
│   └── app_config.dart        # Environment config (dev/staging/prod)
├── model/
│   ├── camera_model.dart
│   └── alert_model.dart
├── provider/
│   ├── auth_provider.dart     # Login + user role
│   ├── camera_provider.dart   # Camera list + controls
│   └── alert_provider.dart    # Alerts + unread count
├── screens/
│   ├── splash_screen.dart     # Animated splash
│   ├── login_screen.dart
│   ├── role_select_screen.dart
│   ├── dash_board.dart        # Main 3-tab dashboard
│   ├── camera_tab.dart        # Cameras + Analytics + Alerts tabs
│   ├── camera_card.dart
│   ├── camera_details.dart
│   ├── camera_broad_cast.dart # Broadcaster (camera phone)
│   ├── live_view.dart         # Viewer (monitor phone)
│   ├── alert_screen.dart
│   ├── people_count.dart
│   ├── setting_screen.dart
│   ├── app_theme.dart
│   ├── routes.dart
│   └── status_dots.dart
├── services/
│   ├── webrtc_service.dart    # WebRTC peer connection
│   └── signaling_service.dart # WebSocket signaling
└── sharedWidget/
    └── shared_widged.dart     # GlassCard widget

signaling/
├── server.js                  # Node.js WebSocket signaling server
├── package.json
├── railway.toml               # Railway deploy config
└── render.yaml                # Render.com deploy config
```

---

## Getting Started

### 1. Clone the repo

```bash
git clone https://github.com/techproarvind/smart_security_camera.git
cd smart_security_camera
flutter pub get
```

### 2. Start the signaling server (local)

```bash
cd signaling
npm install
node server.js
# Server runs at ws://localhost:8080
```

### 3. Run the Flutter app

```bash
# Local WiFi (replace IP with your machine's IP)
flutter run \
  --dart-define=SIGNAL_HOST=192.168.1.34:8080 \
  --dart-define=SIGNAL_SECURE=false
```

### 4. Select roles on two phones

- **Phone 1** → Select **Camera Device** → tap **Go Live**
- **Phone 2** → Select **Viewer / Monitor** → tap **Watch Live**

Both phones must be on the same WiFi (or use the deployed server below).

---

## Deploy Signaling Server (Free)

For testing over the internet (different networks, real devices):

### Render.com (Free — no credit card)

1. Go to **render.com** → New → Web Service
2. Connect `techproarvind/smart_security_camera`
3. Set **Root Directory** → `signaling`
4. Build command: `npm install`
5. Start command: `node server.js`
6. Instance type: **Free**
7. Deploy → get URL like `https://smartcam-signaling.onrender.com`

Then run the app with:
```bash
flutter run \
  --dart-define=SIGNAL_HOST=smartcam-signaling.onrender.com \
  --dart-define=SIGNAL_SECURE=true
```

Health check: `https://smartcam-signaling.onrender.com/health`

---

## Environment Configuration

| Environment | SIGNAL_HOST | SIGNAL_SECURE |
|---|---|---|
| Local dev | `192.168.1.34:8080` | `false` |
| Staging | `staging-signal.yourapp.com` | `true` |
| Production | `signal.yourapp.com` | `true` |

Build for production:
```bash
flutter build appbundle \
  --dart-define=SIGNAL_HOST=signal.yourapp.com \
  --dart-define=SIGNAL_SECURE=true
```

---

## Demo Credentials

```
Email:    admin@smartcam.app
Password: 123456
```

---

## Platforms

- Android (API 21+)
- iOS (13+)
