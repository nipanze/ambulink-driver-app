<div align="center">
  <img src="assets/images/logo.png" alt="AmbuLink Logo" width="80" />
  <h1>AmbuLink Driver</h1>
  <p><strong>Pulse of the Fleet — Real-Time Emergency Dispatch & Navigation for Uganda</strong></p>

  [![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?style=flat-square&logo=flutter)](https://flutter.dev)
  [![Supabase](https://img.shields.io/badge/Supabase-PostgreSQL-green?style=flat-square&logo=supabase)](https://supabase.com)
  [![Firebase](https://img.shields.io/badge/Firebase-FCM-orange?style=flat-square&logo=firebase)](https://firebase.google.com)
</div>

---

## 📌 Overview

**AmbuLink Driver** is the dedicated mobile interface for ambulance responders within the AmbuLink ecosystem. While the [AmbuLink Web Platform](https://github.com/your-org/ambulink-web) handles coordination and patient bookings, this Flutter application serves as the critical link between the dispatcher and the road.

It allows drivers to receive instant emergency SOS alerts, track their own position with high precision, and navigate directly to patients in need.

> *"Turning every ambulance into a smart, data-driven life-saving unit."*

## 🚑 Driver Workflow

1. **Go Online**: Simple toggle to signal availability to the autonomous dispatcher.
2. **Receive Emergency**: Instant full-screen notification with patient details and pickup location.
3. **Accept & Navigate**: One-tap acceptance with immediate transition to Google Maps navigation.
4. **En-Route Updates**: Automatic status pushes ("Assigned" -> "En Route" -> "At Scene") to keep patients and admins informed.
5. **Complete Trip**: Log the outcome and return to the available queue.

## ✨ Key Features

- **Real-time GPS Sync**: High-frequency location updates pushed to Supabase PostgREST for fleet visibility.
- **Smart Dispatch Alerts**: Integrated with Firebase Cloud Messaging (FCM) for low-latency notifications.
- **Precision Navigation**: Native Google Maps integration with real-time traffic considerations.
- **Operational Dashboard**: Monitor ratings, trip history, and driver level (Basic/Pro/Advanced).
- **Offline Resilience**: Graceful handling of connectivity drops with status caching.

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter (Dart) |
| State Management | Provider |
| Backend / API | Supabase (PostgreSQL / Edge Functions) |
| Real-Time | Supabase Realtime & WebSockets |
| Position Tracking | Geolocator (High Accuracy) |
| Notifications | Firebase Cloud Messaging (FCM) |
| Maps / Navigation | Google Maps Flutter |

## 📁 Project Structure

```bash
lib/
├── models/         # Data structures (Booking, Driver, User)
├── screens/        # UI Views (Login, Home, Navigation, History, Profile)
├── services/       # Core Logic (Auth, Location tracking, Notifications)
├── widgets/        # Reusable UI components (Status badges, Info cards)
└── main.dart       # App initialization and theme configuration
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>= 3.0.0)
- Android Studio / VS Code
- A valid `google_maps_api_key`
- Firebase project configuration (`google-services.json`)

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-org/ambulink-driver-app.git
   cd ambulink-driver-app
   ```

2. **Configure Environment Variables**:
   Create a `.env.local` in the root (which the app reads via custom initialization) and add your keys:
   ```env
   NEXT_PUBLIC_SUPABASE_URL=your_url
   NEXT_PUBLIC_SUPABASE_ANON_KEY=your_key
   NEXT_PUBLIC_GOOGLE_MAPS_KEY=your_google_maps_key
   ```

3. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

4. **Initialize Firebase**:
   Ensure `google-services.json` is placed in `android/app/`.

5. **Run the App**:
   ```bash
   flutter run
   ```

## 🗺️ Operational Focus: Mbarara City

The system is currently optimized and localized for **Mbarara City**, Uganda. All navigation buffers and ETA calculations are tuned for the Western Uganda road network.

---

## 👨‍💻 Team

Developed by students at **Kampala International University — School of Mathematics and Computing**.

| Name | Student ID |
|---|---|
| Tumusiime Mahad | 2023-08-20137 |
| Mugisha Abdul | 2023-08-21509 |
| Kato Ashraf | 2023-08-19539 |

**Academic Supervisor:** Mr. Tumwebaze Wilson  

---

© 2026 AmbuLink. Built in Uganda 🇺🇬 For Uganda.