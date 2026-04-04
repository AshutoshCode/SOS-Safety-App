import React from 'react';
import { StyleSheet, View, Text, TouchableOpacity, ScrollView, Alert } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { User, Mail, ShieldCheck, LogOut, ChevronRight, Crown } from 'lucide-react-native';
import { theme } from '../theme/theme';
import ScreenHeader from '../components/ScreenHeader';
import { useAuth } from '../hooks/useAuth';

const SettingsScreen = () => {
  const { user, userData, signOut } = useAuth();

  const handleSignOut = () => {
    Alert.alert(
      "Sign Out",
      "Are you sure you want to log out of Guardian SOS?",
      [
        { text: "Cancel", style: "cancel" },
        { text: "Sign Out", style: "destructive", onPress: signOut }
      ]
    );
  };

  return (
    <SafeAreaView style={styles.container}>
      <ScreenHeader title="SETTINGS" />
      
      <ScrollView contentContainerStyle={styles.scrollContent}>
        <View style={styles.profileCard}>
          <View style={styles.avatar}>
            <Text style={styles.avatarText}>
              {userData?.firstName?.[0] || user?.email?.[0]?.toUpperCase() || 'U'}
            </Text>
            <View style={styles.crownContainer}>
              <Crown color={theme.colors.accent} size={14} />
            </View>
          </View>
          <Text style={styles.userName}>{userData?.firstName} {userData?.lastName}</Text>
          <Text style={styles.userEmail}>{user?.email}</Text>
          <View style={styles.statusBadge}>
            <ShieldCheck color={theme.colors.success} size={14} />
            <Text style={styles.statusText}>PREMIUM PROTECTION ACTIVE</Text>
          </View>
        </View>

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>ACCOUNT</Text>
          <SettingItem 
            icon={<User color={theme.colors.slate} size={20}/>} 
            label="Profile Details" 
            onPress={() => Alert.alert("Profile", `Name: ${userData?.firstName} ${userData?.lastName}\nEmail: ${user?.email}`)}
          />
          <SettingItem 
            icon={<Mail color={theme.colors.slate} size={20}/>} 
            label="Email Notification" 
            onPress={() => Alert.alert("Notifications", "Emergency email alerts are currently ENABLED.")}
          />
        </View>

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>PREFERENCES</Text>
          <SettingItem 
            icon={<ShieldCheck color={theme.colors.slate} size={20}/>} 
            label="Security Passcode" 
            onPress={() => Alert.alert("Security", "Passcode protection is active for all SOS triggers.")}
          />
        </View>

        <TouchableOpacity 
          style={styles.signOutButton} 
          onPress={handleSignOut}
        >
          <LogOut color={theme.colors.error} size={20} />
          <Text style={styles.signOutText}>Sign Out of All Devices</Text>
        </TouchableOpacity>

        <Text style={styles.versionText}>Guardian SOS v1.15.5{"\n"}Elite Personal Protection System</Text>
      </ScrollView>
    </SafeAreaView>
  );
};

const SettingItem = ({ icon, label, onPress }) => (
  <TouchableOpacity style={styles.settingItem} onPress={onPress}>
    <View style={styles.settingLeft}>
      {icon}
      <Text style={styles.settingLabel}>{label}</Text>
    </View>
    <ChevronRight color={theme.colors.glass} size={18} />
  </TouchableOpacity>
);

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: theme.colors.primary,
  },
  scrollContent: {
    padding: theme.spacing.lg,
  },
  profileCard: {
    alignItems: 'center',
    paddingVertical: theme.spacing.xxl,
    backgroundColor: theme.colors.glass,
    borderRadius: theme.borderRadius.lg,
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.05)',
    marginBottom: theme.spacing.xl,
  },
  avatar: {
    width: 80,
    height: 80,
    borderRadius: 40,
    backgroundColor: 'rgba(255, 255, 255, 0.1)',
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: theme.spacing.md,
    position: 'relative',
  },
  crownContainer: {
    position: 'absolute',
    top: -5,
    right: -5,
    backgroundColor: theme.colors.primary,
    padding: 4,
    borderRadius: 12,
    borderWidth: 1,
    borderColor: theme.colors.accent,
  },
  avatarText: {
    fontSize: 32,
    fontWeight: 'bold',
    color: theme.colors.white,
  },
  userName: {
    fontSize: 20,
    fontWeight: 'bold',
    color: theme.colors.white,
    marginBottom: 4,
  },
  userEmail: {
    fontSize: 14,
    color: theme.colors.slate,
    marginBottom: theme.spacing.lg,
  },
  statusBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: theme.colors.success + '15',
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 20,
    borderWidth: 1,
    borderColor: theme.colors.success + '30',
  },
  statusText: {
    fontSize: 10,
    fontWeight: '900',
    color: theme.colors.success,
    marginLeft: 6,
    letterSpacing: 1,
  },
  section: {
    marginBottom: theme.spacing.xl,
  },
  sectionTitle: {
    fontSize: 12,
    fontWeight: 'bold',
    color: theme.colors.slate,
    letterSpacing: 1,
    marginBottom: theme.spacing.md,
    marginLeft: 4,
  },
  settingItem: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingVertical: theme.spacing.lg,
    paddingHorizontal: theme.spacing.md,
    backgroundColor: theme.colors.glass,
    borderRadius: theme.borderRadius.md,
    marginBottom: theme.spacing.sm,
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.03)',
  },
  settingLeft: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  settingLabel: {
    color: theme.colors.white,
    fontSize: 16,
    marginLeft: theme.spacing.md,
  },
  signOutButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: theme.spacing.lg,
    marginTop: theme.spacing.xl,
    borderTopWidth: 1,
    borderTopColor: 'rgba(255, 255, 255, 0.1)',
  },
  signOutText: {
    color: theme.colors.error,
    fontWeight: 'bold',
    fontSize: 16,
    marginLeft: 10,
  },
  versionText: {
    textAlign: 'center',
    color: theme.colors.slate,
    fontSize: 10,
    marginTop: theme.spacing.xxl,
    lineHeight: 18,
    opacity: 0.5,
  },
});

export default SettingsScreen;
