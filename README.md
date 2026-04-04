# Guardian SOS - Elite Personal Safety System 🛡️🆘

Guardian SOS is a mission-critical, "Panic-Proof" emergency response application built with **React Native (Expo)** and **Firebase**. It provides a one-touch, high-reliability safety net for individuals in high-stress situations.

## 🚀 Ready-to-Run Features

*   **SOS Trigger (Long-Press)**: Prevents accidental activations while ensuring immediate response. Includes **Haptic Feedback** for eyes-free confirmation.
*   **Live GPS Intelligence**: Captures and synchronizes real-time location data with the cloud every 10 meters.
*   **Emergency Contacts (Protectors)**: Secure, user-specific management of personal emergency responders in a live Firestore database.
*   **Automated SMS Rescue**: Automatically generates emergency messages to all "Protectors" with a direct Google Maps link.
*   **Alert History**: Maintains a complete, secure log of all SOS activations with precise timestamps and coordinates.
*   **Premium Aesthetics**: High-contrast dark mode design with sleek glassmorphism components for optimal readability in low light.

## 🛠️ Technical Stack

*   **Framework**: React Native (Expo SDK 54)
*   **Backend**: Firebase Firestore (NoSQL Database), Firebase Authentication
*   **Navigation**: Expo Router (v3)
*   **Components**: Lucide-React-Native Icons, React Native Safe Area Context
*   **Persistence**: @react-native-async-storage/async-storage

## 📦 Get Started

1.  **Clone & Install**:
    ```bash
    git clone https://github.com/AshutoshCode/SOS-Safety-App.git
    npm install
    ```

2.  **Start the Project**:
    ```bash
    # For local same-network testing
    npx expo start
    
    # For remote/off-site testing
    npx expo start --tunnel
    ```

3.  **Test on Device**:
    Download the **Expo Go** app from the Play Store or App Store and scan the QR code.

## 🛡️ Security & Privacy
*   All user data is isolated via **Firebase Security Rules**.
*   Emergency alerts are private and accessible only to the authenticated user and their rescue logs.
*   The system is designed for **100% session persistence** to ensure you stay protected even after unexpected reboots.

---
*Created for Guardian SOS - 24/7 Elite Personal Protection.*
