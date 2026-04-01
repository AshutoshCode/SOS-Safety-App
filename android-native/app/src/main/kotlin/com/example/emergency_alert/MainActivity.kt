package com.example.emergency_alert

import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import com.example.emergency_alert.services.EmergencyService
import com.example.emergency_alert.services.SmsService
import com.example.emergency_alert.ui.screens.AuthScreen
import com.example.emergency_alert.ui.screens.ContactListScreen
import com.example.emergency_alert.ui.screens.HomeScreen
import com.example.emergency_alert.ui.theme.EmergencyAlertTheme

class MainActivity : ComponentActivity() {
    private val smsService = SmsService()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            EmergencyAlertTheme {
                var currentScreen by remember { mutableStateOf("auth") }

                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    when (currentScreen) {
                        "auth" -> AuthScreen(onLoginSuccess = { currentScreen = "home" })
                        "home" -> HomeScreen(onTriggerSOS = { 
                            triggerSOS()
                        })
                        "contacts" -> ContactListScreen(onBack = { currentScreen = "home" })
                    }
                }
            }
        }
    }

    private fun triggerSOS() {
        // 1. Send SMS to pre-saved contacts (Dummy numbers for now)
        smsService.sendSms("+1234567890", "EMERGENCY! I need help. My location will be shared soon.")
        
        // 2. Start Background Service for Location and Shake
        val intent = Intent(this, EmergencyService::class.java)
        startService(intent)
    }
}
