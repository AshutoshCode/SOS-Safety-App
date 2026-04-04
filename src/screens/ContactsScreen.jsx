import React, { useState } from 'react';
import { StyleSheet, View, Text, ScrollView, TextInput, TouchableOpacity, ActivityIndicator, KeyboardAvoidingView, Platform } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Plus, UserPlus } from 'lucide-react-native';
import { theme } from '../theme/theme';
import ScreenHeader from '../components/ScreenHeader';
import ContactItem from '../components/ContactItem';
import { useContacts } from '../hooks/useContacts';

const ContactsScreen = () => {
  const { contacts, isLoading, error, addContact, removeContact, clearError } = useContacts();
  const [name, setName] = useState('');
  const [phone, setPhone] = useState('');
  const [isAdding, setIsAdding] = useState(false);

  const handleAdd = async () => {
    if (!name || !phone) return;
    await addContact(name, phone);
    setName('');
    setPhone('');
    setIsAdding(false);
  };

  return (
    <SafeAreaView style={styles.container}>
      <ScreenHeader title="EMERGENCY CONTACTS" />
      
      <KeyboardAvoidingView 
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        style={styles.flex}
      >
        <ScrollView contentContainerStyle={styles.scrollContent}>
          <Text style={styles.description}>
            These contacts will be notified via SMS the moment you trigger an SOS alert.
          </Text>

          {isAdding ? (
            <View style={styles.addForm}>
              <TextInput
                style={styles.input}
                placeholder="Full Name"
                placeholderTextColor={theme.colors.slate}
                value={name}
                onChangeText={setName}
              />
              <TextInput
                style={styles.input}
                placeholder="Phone Number"
                placeholderTextColor={theme.colors.slate}
                keyboardType="phone-pad"
                value={phone}
                onChangeText={setPhone}
              />
              <View style={styles.formButtons}>
                <TouchableOpacity 
                  style={[styles.formButton, styles.cancelButton]} 
                  onPress={() => setIsAdding(false)}
                >
                  <Text style={styles.cancelText}>Cancel</Text>
                </TouchableOpacity>
                <TouchableOpacity 
                  style={[styles.formButton, styles.saveButton]} 
                  onPress={handleAdd}
                >
                  <Text style={styles.saveText}>Save Contact</Text>
                </TouchableOpacity>
              </View>
            </View>
          ) : (
            <TouchableOpacity 
              style={styles.addButton} 
              onPress={() => setIsAdding(true)}
            >
              <UserPlus color={theme.colors.white} size={20} />
              <Text style={styles.addButtonText}>Add New Contact</Text>
            </TouchableOpacity>
          )}

          <View style={styles.listSection}>
            <Text style={styles.sectionTitle}>YOUR PROTECTORS ({contacts.length})</Text>
            
            {isLoading && !isAdding ? (
              <ActivityIndicator color={theme.colors.emergency} style={styles.loader} />
            ) : contacts.length > 0 ? (
              contacts.map(contact => (
                <ContactItem 
                  key={contact.id}
                  name={contact.name}
                  phoneNumber={contact.phoneNumber}
                  onDelete={() => removeContact(contact.id)}
                />
              ))
            ) : (
              <View style={styles.emptyContainer}>
                <Text style={styles.emptyText}>No contacts added yet.</Text>
              </View>
            )}
          </View>
        </ScrollView>
      </KeyboardAvoidingView>

      {error && (
        <TouchableOpacity style={styles.errorBanner} onPress={clearError}>
          <Text style={styles.errorText}>{error}</Text>
        </TouchableOpacity>
      )}
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: theme.colors.primary,
  },
  flex: {
    flex: 1,
  },
  scrollContent: {
    padding: theme.spacing.lg,
  },
  description: {
    fontSize: 14,
    color: theme.colors.slate,
    lineHeight: 20,
    marginBottom: theme.spacing.xl,
  },
  addButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: 'rgba(255, 255, 255, 0.05)',
    padding: theme.spacing.lg,
    borderRadius: theme.borderRadius.md,
    borderWidth: 1,
    borderStyle: 'dashed',
    borderColor: 'rgba(255, 255, 255, 0.2)',
  },
  addButtonText: {
    color: theme.colors.white,
    fontWeight: 'bold',
    marginLeft: 10,
  },
  addForm: {
    backgroundColor: theme.colors.glass,
    padding: theme.spacing.lg,
    borderRadius: theme.borderRadius.md,
    borderWidth: 1,
    borderColor: theme.colors.emergency + '40',
  },
  input: {
    backgroundColor: 'rgba(255, 255, 255, 0.05)',
    height: 50,
    borderRadius: theme.borderRadius.sm,
    paddingHorizontal: theme.spacing.md,
    color: theme.colors.white,
    marginBottom: theme.spacing.md,
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.1)',
  },
  formButtons: {
    flexDirection: 'row',
    justifyContent: 'flex-end',
  },
  formButton: {
    paddingVertical: 10,
    paddingHorizontal: 20,
    borderRadius: theme.borderRadius.sm,
    marginLeft: 10,
  },
  cancelButton: {
    backgroundColor: 'rgba(255, 255, 255, 0.1)',
  },
  saveButton: {
    backgroundColor: theme.colors.emergency,
  },
  cancelText: {
    color: theme.colors.slate,
    fontWeight: 'bold',
  },
  saveText: {
    color: theme.colors.white,
    fontWeight: 'bold',
  },
  listSection: {
    marginTop: theme.spacing.xl,
  },
  sectionTitle: {
    fontSize: 12,
    fontWeight: 'bold',
    color: theme.colors.slate,
    letterSpacing: 1,
    marginBottom: theme.spacing.md,
  },
  loader: {
    marginTop: theme.spacing.xl,
  },
  emptyContainer: {
    alignItems: 'center',
    padding: theme.spacing.xl,
  },
  emptyText: {
    color: theme.colors.slate,
    fontStyle: 'italic',
  },
  errorBanner: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    backgroundColor: theme.colors.emergency,
    padding: theme.spacing.md,
    alignItems: 'center',
  },
  errorText: {
    color: theme.colors.white,
    fontWeight: 'bold',
  },
});

export default ContactsScreen;
