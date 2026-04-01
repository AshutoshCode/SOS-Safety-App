package com.example.emergency_alert

import android.app.Application
import com.google.firebase.FirebaseApp

class EmergencyApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        FirebaseApp.initializeApp(this)
    }
}
