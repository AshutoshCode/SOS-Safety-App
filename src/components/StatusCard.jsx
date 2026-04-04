import React from 'react';
import { StyleSheet, View, Text } from 'react-native';
import { theme } from '../theme/theme';
import { ShieldCheck, ShieldAlert, WifiOff, MapPin, Mic } from 'lucide-react-native';

const StatusCard = ({ isActive, isTracking, isRecording, isOffline }) => {
  return (
    <View style={styles.card}>
      <View style={[styles.iconContainer, { backgroundColor: isActive ? theme.colors.emergency + '20' : theme.colors.success + '20' }]}>
        {isActive ? (
          <ShieldAlert color={theme.colors.emergency} size={32} />
        ) : (
          <ShieldCheck color={theme.colors.success} size={32} />
        )}
      </View>
      <View style={styles.content}>
        <Text style={styles.title}>{isActive ? 'EMERGENCY ACTIVE' : 'SYSTEM READY'}</Text>
        <Text style={styles.subtitle}>{isActive ? 'Help is on the way' : 'Scanning for danger...'}</Text>
      </View>
      <View style={styles.badges}>
        {isTracking && <MapPin color={theme.colors.success} size={16} style={styles.badge} />}
        {isRecording && <Mic color={theme.colors.emergency} size={16} style={styles.badge} />}
        {isOffline && <WifiOff color={theme.colors.error} size={16} style={styles.badge} />}
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  card: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: theme.spacing.lg,
    backgroundColor: theme.colors.glass,
    borderRadius: theme.borderRadius.lg,
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.1)',
    marginVertical: theme.spacing.md,
  },
  iconContainer: {
    width: 60,
    height: 60,
    borderRadius: 30,
    alignItems: 'center',
    justifyContent: 'center',
  },
  content: {
    flex: 1,
    marginLeft: theme.spacing.md,
  },
  title: {
    fontSize: 16,
    fontWeight: 'bold',
    color: theme.colors.white,
    letterSpacing: 1,
  },
  subtitle: {
    fontSize: 12,
    color: theme.colors.slate,
    marginTop: 2,
  },
  badges: {
    flexDirection: 'row',
  },
  badge: {
    marginLeft: theme.spacing.xs,
  },
});

export default StatusCard;
