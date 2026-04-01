package com.example.emergency_alert.services

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.telephony.SmsManager
import androidx.core.content.ContextCompat

/**
 * Native Android SMS service for offline SMS sending
 * Uses Android SmsManager to send SMS (works offline - queued by system)
 */
class SmsService(private val context: Context) {

    /**
     * Send SMS message to phone number
     * @param phoneNumber Recipient phone number
     * @param message Message text
     * @return true if SMS queued successfully, false otherwise
     */
    fun sendSms(phoneNumber: String, message: String): Boolean {
        return try {
            val smsManager = context.getSystemService(Context.TELEPHONY_SERVICE) as SmsManager
            val sentIntent = PendingIntent.getBroadcast(
                context,
                0,
                Intent("SMS_SENT"),
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            smsManager.sendTextMessage(
                phoneNumber,
                null,
                message,
                sentIntent,
                null
            )

            true
        } catch (e: Exception) {
            android.util.Log.e("SmsService", "Error sending SMS: ${e.message}")
            false
        }
    }

    /**
     * Send SMS to multiple recipients
     * @param phoneNumbers List of phone numbers
     * @param message Message text
     * @return Map of phone number to success/failure
     */
    fun sendSmsToMultiple(phoneNumbers: List<String>, message: String): Map<String, Boolean> {
        return phoneNumbers.associateWith { phoneNumber ->
            sendSms(phoneNumber, message)
        }
    }

    /**
     * Check if SMS permission is granted
     */
    fun hasSmsPermission(): Boolean {
        return ContextCompat.checkSelfPermission(
            context,
            android.Manifest.permission.SEND_SMS
        ) == android.content.pm.PackageManager.PERMISSION_GRANTED
    }
}
