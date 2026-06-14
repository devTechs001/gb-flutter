# ChatWave - Premium Messaging App

Ride the wave of connection. A feature-rich messaging app built with Flutter and Node.js.

## Architecture

- **Frontend**: Flutter (Android/iOS) with Provider state management
- **Backend**: Node.js + Express + Socket.IO (in-memory storage)
- **Real-time**: Socket.IO for messaging, typing indicators, and calls

## Features

### Chat Features
- Individual and group messaging
- Text, image, video, audio, and document sharing
- Location sharing and contact sharing
- Message reactions, replies, forwarding, editing, and deletion
- Read receipts (sent/delivered/read)
- Emoji picker, voice recording
- End-to-end encryption indicator

### Status/Stories
- Post text/image/video status updates
- 24-hour auto-expiry
- View tracking
- Mute status from specific users

### Voice/Video Calls
- Audio and video call logging
- Real-time call signaling via Socket.IO
- Call history with missed/answered/outgoing status

### Authentication
- Phone number OTP verification
- Profile setup with avatar, name, and status
- JWT-based session management

### UI Features
- Material Design 3 (Material You)
- Dark/Light theme support
- Splash screen with animation
- Contact list with registration status
- Group management (create, add/remove participants)
- Chat wallpapers, font size, and other settings

## Setup Instructions

### Backend Deployment (Render)

1. Push the `backend/` folder to a GitHub repo
2. On Render, create a new Web Service
3. Connect your GitHub repo
4. Use these settings:
   - **Build Command**: `npm install`
   - **Start Command**: `node server.js`
   - **Plan**: Free
5. The `render.yaml` in the backend folder auto-configures these

### Alternative: Local Backend

```bash
cd backend
npm install
node server.js
# Server starts on http://localhost:3000
```

### Flutter App Setup

1. Open `lib/config/app_config.dart`
2. Update `backendUrl` and `socketUrl` to your backend URL:
   ```dart
   static const String backendUrl = 'https://your-app.onrender.com';
   static const String socketUrl = 'https://your-app.onrender.com';
   ```
3. Run the app:
   ```bash
   flutter pub get
   flutter run
   ```

## Project Structure

```
chatwave/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── config/                      # App configuration
│   ├── models/                      # Data models
│   ├── providers/                   # State management
│   ├── screens/                     # All screens
│   │   ├── auth/                    # Login, OTP, Profile setup
│   │   ├── home/                    # Main tab screen
│   │   ├── chat/                    # Chat list, chat screen, group
│   │   ├── status/                  # Status list, viewer, creator
│   │   ├── calls/                   # Call log, call screen
│   │   ├── profile/                 # User profile
│   │   └── settings/                # Settings
│   ├── services/                    # API, Auth, Chat, Call services
│   ├── theme/                       # App theme and colors
│   ├── utils/                       # Helpers, validators, constants
│   └── widgets/                     # Reusable widgets
├── backend/
│   ├── server.js                    # Express + Socket.IO server
│   ├── routes/                      # API routes
│   ├── config/                      # Backend config
│   ├── render.yaml                  # Render deployment config
│   └── package.json
└── assets/
    ├── images/                      # App images
    ├── icons/                       # App icons
    └── lottie/                      # Lottie animations
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/send-otp` | Send OTP for phone verification |
| POST | `/api/auth/verify-otp` | Verify OTP and get JWT |
| POST | `/api/auth/register` | Register user profile |
| GET | `/api/auth/user/:uid` | Get user data |
| PUT | `/api/auth/user/:uid` | Update user profile |
| GET | `/api/chats/:userId` | Get user's chats |
| POST | `/api/chats` | Create new chat |
| GET | `/api/chats/:chatId/messages` | Get chat messages |
| POST | `/api/chats/:chatId/messages` | Send message |
| POST | `/api/media/upload` | Upload file |
| GET | `/api/calls/:userId` | Get call history |
| POST | `/api/calls/log` | Log a call |

## Tech Stack

- **Flutter 3.41** with Dart 3.11
- **Provider** for state management
- **Socket.IO** for real-time communication
- **Node.js** with Express
- **JWT** for authentication
# ChatWave App
