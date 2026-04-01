package com.example.emergency_alert.data

import com.google.firebase.firestore.FirebaseFirestore
import kotlinx.coroutines.tasks.await

data class Alert(
    val id: String = "",
    val userId: String = "",
    val status: String = "active",
    val timestamp: Long = System.currentTimeMillis()
)

class AlertRepository {
    private val db = FirebaseFirestore.getInstance()

    suspend fun triggerAlert(userId: String): String? {
        val alert = Alert(userId = userId)
        return try {
            val docRef = db.collection("alerts").add(alert).await()
            docRef.id
        } catch (e: Exception) {
            null
        }
    }
}
