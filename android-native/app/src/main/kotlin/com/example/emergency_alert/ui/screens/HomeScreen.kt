package com.example.emergency_alert.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

@Composable
fun HomeScreen(onTriggerSOS: () -> Unit) {
    Column(
        modifier = Modifier.fillMaxSize(),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text("Emergency Status: SAFE", fontSize = 20.sp)
        Spacer(modifier = Modifier.height(50.dp))
        Button(
            onClick = onTriggerSOS,
            modifier = Modifier.size(200.dp),
            shape = CircleShape,
            colors = ButtonDefaults.buttonColors(containerColor = Color.Red)
        ) {
            Text("SOS", fontSize = 40.sp, color = Color.White)
        }
        Spacer(modifier = Modifier.height(50.dp))
        Text("Shake your phone to trigger alert", fontSize = 14.sp, color = Color.Gray)
    }
}
