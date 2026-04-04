import React from 'react';
import { StyleSheet, View, Text, TouchableOpacity } from 'react-native';
import { Trash2, Phone } from 'lucide-react-native';
import { theme } from '../theme/theme';

const ContactItem = ({ name, phoneNumber, onDelete }) => {
  return (
    <View style={styles.card}>
      <View style={styles.content}>
        <Text style={styles.name}>{name}</Text>
        <View style={styles.phoneContainer}>
          <Phone color={theme.colors.slate} size={14} />
          <Text style={styles.phone}>{phoneNumber}</Text>
        </View>
      </View>
      <TouchableOpacity onPress={onDelete} style={styles.deleteButton}>
        <Trash2 color={theme.colors.error} size={20} />
      </TouchableOpacity>
    </View>
  );
};

const styles = StyleSheet.create({
  card: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    padding: theme.spacing.lg,
    backgroundColor: theme.colors.glass,
    borderRadius: theme.borderRadius.md,
    marginBottom: theme.spacing.md,
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.05)',
  },
  content: {
    flex: 1,
  },
  name: {
    fontSize: 18,
    fontWeight: 'bold',
    color: theme.colors.white,
    marginBottom: 4,
  },
  phoneContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  phone: {
    fontSize: 14,
    color: theme.colors.slate,
    marginLeft: 6,
  },
  deleteButton: {
    width: 44,
    height: 44,
    alignItems: 'center',
    justifyContent: 'center',
  },
});

export default ContactItem;
