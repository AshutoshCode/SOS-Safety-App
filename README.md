<div align="center">
  <img src="./assets/images/icon.png" alt="Guardian SOS Logo" width="120" />

  # Guardian SOS
  **Elite Personal Safety & Emergency Response System**

  [![React Native](https://img.shields.io/badge/React_Native-20232A?style=for-the-badge&logo=react&logoColor=61DAFB)](https://reactnative.dev/)
  [![Expo](https://img.shields.io/badge/Expo-000020?style=for-the-badge&logo=expo&logoColor=white)](https://expo.dev/)
  [![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com/)
  [![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

  <p align="center">
    <strong>A mission-critical, "Panic-Proof" application engineered to provide immediate, reliable communication and live GPS tracking during high-stress emergency situations.</strong>
  </p>
</div>

<hr />

## 🌟 Overview

Guardian SOS is designed to be the ultimate safety net. Traditional emergency apps often suffer from accidental triggers or overly complex interfaces that fail during real panic scenarios. We solved this by engineering a **Long-Press Activation Protocol** paired with **Instant Haptic Feedback**, ensuring that when you need help, it is dispatched flawlessly every single time.

## ✨ Core Capabilities

### 🛡️ Panic-Proof SOS Engine
*   **Tactile Confirmation**: High-contrast UI combined with device-level haptics guarantees eyes-free confirmation.
*   **Anti-False Alarm**: Long-press verification prevents accidental triggers in pockets or bags.

### 📡 Real-Time Intelligence
*   **Live Payload**: Dispatches SMS containing precise latitude/longitude to designated Protectors.
*   **Continuous Tracking**: Background telemetry updates your secure cloud profile every 10 meters.

### 👥 Protector Network (Contacts)
*   **Cloud-Synced Roster**: Securely manage your emergency contacts.
*   **Instant Multi-Dispatch**: Notifies all active Protectors simultaneously upon SOS activation.

### 📜 Indelible Audit Trail
*   **Encrypted History**: Every activation is securely logged in Firebase Firestore.
*   **Post-Event Analysis**: Review timestamps, resolution status, and complete location data for any past event.

---

## 🏗️ System Architecture & Tech Stack

This application is built for maximum resilience and zero-latency execution.

*   **Frontend Framework**: React Native via **Expo** for cross-platform supremacy.
*   **Routing Architecture**: **Expo Router** providing stateful, file-based navigation.
*   **Backend Infrastructure**: **Firebase**
    *   *Authentication*: Secure, persistent user sessions.
    *   *Firestore*: Real-time NoSQL database for telemetry and contact management.
*   **UI/UX Design**: Custom **Glassmorphism** aesthetic utilizing `lucide-react-native` for scalable iconography.
*   **Device Integration**: OS-level sensor integration using `expo-location`, `expo-sms`, and `expo-haptics`.

---

## 🚀 Quick Start Guide

### Prerequisites
*   Node.js (v18 or newer)
*   Expo Go App on your Mobile Device (iOS/Android)

### Installation

1.  **Clone the Repository**
    ```bash
    git clone https://github.com/AshutoshCode/SOS-Safety-App.git
    cd SOS-Safety-App
    ```

2.  **Install Dependencies**
    ```bash
    npm install
    ```

3.  **Launch the Development Server**
    ```bash
    # For local testing (PC and Phone on same Wi-Fi)
    npx expo start

    # For remote testing (Tunneling via Ngrok)
    npx expo start --tunnel --clear
    ```

4.  **Deploy to Device**
    Open the **Expo Go** app on your phone and scan the QR code generated in your terminal to begin testing.

---

## 🔒 Security & Privacy Posture

*   **Data Sovereignty**: Telemetry and contact data are strictly isolated using robust Firebase Security Rules (`request.auth != null`).
*   **Ephemeral Tracking**: Background location tracking engages **only** during an active SOS event and terminates upon resolution.
*   **Session Resilience**: Leverages secure asynchronous storage to guarantee session persistence, ensuring the app is always armed and ready without requiring re-authentication during a crisis.

---
<div align="center">
  <sub>Built with ❤️ for a safer world.</sub>
</div>
