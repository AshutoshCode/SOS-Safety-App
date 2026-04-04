import React from 'react';
import { StyleSheet, View, Text, TouchableOpacity, ScrollView } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { theme } from '../theme/theme';
import StatusCard from '../components/StatusCard';
import PremiumSOSButton from '../components/PremiumSOSButton';
import { useEmergency } from '../hooks/useEmergency';
import { useAuth } from '../hooks/useAuth';
import { Settings, Users, History, LogOut } from 'lucide-react-native';

const HomeScreen = () => {
  const router = useRouter();
  const { triggerSOS, resolveAlert, activeAlert, isLoading, isTracking, isRecording, error, clearError } = useEmergency();
  const { user, signOut } = useAuth();

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.headerTitle}>GUARDIAN SOS</Text>
        <TouchableOpacity onPress={() => signOut()}>
           <LogOut color={theme.colors.white} size={24} />
        </TouchableOpacity>
      </View>

      <ScrollView contentContainerStyle={styles.scrollContent}>
        <StatusCard 
          isActive={!!activeAlert} 
          isTracking={isTracking} 
          isRecording={isRecording} 
        />

        <View style={styles.main}>
          <PremiumSOSButton 
            onLongPress={triggerSOS}
            isLoading={isLoading}
          />
          
          {activeAlert && (
            <TouchableOpacity style={styles.resolveButton} onPress={resolveAlert}>
              <Text style={styles.resolveText}>I AM SAFE - RESOLVE ALERT</Text>
            </TouchableOpacity>
          )}
        </View>

        <View style={styles.grid}>
          <MenuButton icon={<Users color="white"/>} label="Contacts" onPress={() => router.push('/contacts')} />
          <MenuButton icon={<History color="white"/>} label="History" onPress={() => router.push('/history')} />
          <MenuButton icon={<Settings color="white"/>} label="Settings" onPress={() => router.push('/settings')} />
        </View>
      </ScrollView>

      {error && (
        <TouchableOpacity style={styles.errorBanner} onPress={clearError}>
          <Text style={styles.errorText}>{error}</Text>
        </TouchableOpacity>
      )}
    </SafeAreaView>
  );
};

const MenuButton = ({ icon, label, onPress }) => (
  <TouchableOpacity style={styles.menuButton} onPress={onPress}>
    <View style={styles.menuIcon}>{icon}</View>
    <Text style={styles.menuLabel}>{label}</Text>
  </TouchableOpacity>
);

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: theme.colors.primary,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: theme.spacing.lg,
    paddingTop: theme.spacing.md,
  },
  headerTitle: {
    fontSize: 20,
    fontWeight: '900',
    color: theme.colors.white,
    letterSpacing: 2,
  },
  scrollContent: {
    paddingHorizontal: theme.spacing.lg,
    paddingBottom: theme.spacing.xxl,
  },
  main: {
    alignItems: 'center',
    justifyContent: 'center',
    marginVertical: theme.spacing.xl,
  },
  resolveButton: {
    backgroundColor: theme.colors.accent,
    paddingVertical: theme.spacing.md,
    paddingHorizontal: theme.spacing.xl,
    borderRadius: theme.borderRadius.md,
    marginTop: theme.spacing.lg,
  },
  resolveText: {
    color: theme.colors.white,
    fontWeight: 'bold',
  },
  grid: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: theme.spacing.xl,
  },
  menuButton: {
    width: '30%',
    backgroundColor: theme.colors.glass,
    padding: theme.spacing.md,
    borderRadius: theme.borderRadius.md,
    alignItems: 'center',
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.05)',
  },
  menuIcon: {
    marginBottom: theme.spacing.sm,
  },
  menuLabel: {
    color: theme.colors.slate,
    fontSize: 10,
    fontWeight: 'bold',
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

export default HomeScreen;
