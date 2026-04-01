package com.example.emergency_alert.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

data class Contact(val id: String, val name: String, val phone: String)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ContactListScreen(onBack: () -> Unit) {
    // Dummy state for demonstration
    val contacts = remember { mutableStateListOf(Contact("1", "John Doe", "+1234567890")) }

    Scaffold(
        topBar = {
            TopAppBar(title = { Text("Emergency Contacts") })
        },
        floatingActionButton = {
            FloatingActionButton(onClick = { /* Add contact logic */ }) {
                Icon(Icons.Default.Add, contentDescription = "Add")
            }
        }
    ) { padding ->
        LazyColumn(modifier = Modifier.padding(padding)) {
            items(contacts) { contact ->
                ListItem(
                    headlineContent = { Text(contact.name) },
                    supportingContent = { Text(contact.phone) },
                    trailingContent = {
                        TextButton(onClick = { contacts.remove(contact) }) {
                            Text("Delete", color = MaterialTheme.colorScheme.error)
                        }
                    }
                )
            }
        }
    }
}
