import React, { useState, useEffect } from 'react';
import { StyleSheet, View, Text, ScrollView, ActivityIndicator, TouchableOpacity } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { History as HistoryIcon, MapPin, Calendar, Clock, AlertTriangle } from 'lucide-react-native';
import { theme } from '../theme/theme';
import ScreenHeader from '../components/ScreenHeader';
import { db, auth } from '../services/firebase';
import { collection, query, orderBy, onSnapshot } from 'firebase/firestore';

const HistoryScreen = () => {
  const [alerts, setAlerts] = useState([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    if (!auth.currentUser) {
      setIsLoading(false);
      return;
    }

    const q = query(
      collection(db, `users/${auth.currentUser.uid}/alerts`),
      orderBy('createdAt', 'desc')
    );

    const unsubscribe = onSnapshot(q, (snapshot) => {
      const alertList = snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));
      setAlerts(alertList);
      setIsLoading(false);
    }, (err) => {
      console.error(err);
      setIsLoading(false);
    });

    return () => unsubscribe();
  }, [auth.currentUser]);

  const formatDate = (timestamp) => {
    if (!timestamp) return '...';
    try {
      const date = timestamp.toDate();
      return date.toLocaleDateString();
    } catch (e) {
      return '...';
    }
  };

  const formatTime = (timestamp) => {
    if (!timestamp) return '...';
    try {
      const date = timestamp.toDate();
      return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
    } catch (e) {
      return '...';
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <ScreenHeader title="ALERT HISTORY" />
      
      <ScrollView contentContainerStyle={styles.scrollContent}>
        {isLoading ? (
          <ActivityIndicator color={theme.colors.emergency} style={styles.loader} />
        ) : alerts.length > 0 ? (
          alerts.map(alert => (
            <View key={alert.id} style={styles.alertCard}>
              <View style={styles.cardHeader}>
                <View style={styles.alertType}>
                  <AlertTriangle color={theme.colors.emergency} size={18} />
                  <Text style={styles.alertTypeText}>SOS ACTIVATED</Text>
                </View>
                <View style={[styles.statusBadge, { backgroundColor: alert.status === 'resolved' ? theme.colors.success + '20' : theme.colors.emergency + '20' }]}>
                  <Text style={[styles.statusText, { color: alert.status === 'resolved' ? theme.colors.success : theme.colors.emergency }]}>
                    {alert.status?.toUpperCase() || 'UNKNOWN'}
                  </Text>
                </View>
              </View>

              <View style={styles.details}>
                <View style={styles.detailRow}>
                  <Calendar color={theme.colors.slate} size={14} />
                  <Text style={styles.detailText}>{formatDate(alert.createdAt)}</Text>
                  <View style={styles.separator} />
                  <Clock color={theme.colors.slate} size={14} />
                  <Text style={styles.detailText}>{formatTime(alert.createdAt)}</Text>
                </View>
                
                <View style={styles.detailRow}>
                  <MapPin color={theme.colors.slate} size={14} />
                  <Text style={styles.detailText}>
                    {alert.lastLatitude?.toFixed(4)}, {alert.lastLongitude?.toFixed(4)}
                  </Text>
                </View>
              </View>
            </View>
          ))
        ) : (
          <View style={styles.emptyContainer}>
            <HistoryIcon color={theme.colors.glass} size={64} style={styles.emptyIcon} />
            <Text style={styles.emptyTitle}>No Alerts Yet</Text>
            <Text style={styles.emptySubtitle}>Your SOS history will appear here once triggered.</Text>
          </View>
        )}
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: theme.colors.primary,
  },
  scrollContent: {
    padding: theme.spacing.lg,
  },
  loader: {
    marginTop: theme.spacing.xxl * 2,
  },
  alertCard: {
    backgroundColor: theme.colors.glass,
    borderRadius: theme.borderRadius.md,
    padding: theme.spacing.lg,
    marginBottom: theme.spacing.md,
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.05)',
  },
  cardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: theme.spacing.md,
  },
  alertType: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  alertTypeText: {
    color: theme.colors.white,
    fontWeight: 'bold',
    fontSize: 14,
    marginLeft: 8,
    letterSpacing: 1,
  },
  statusBadge: {
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 12,
  },
  statusText: {
    fontSize: 10,
    fontWeight: 'bold',
  },
  details: {
    gap: 8,
  },
  detailRow: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  detailText: {
    color: theme.colors.slate,
    fontSize: 13,
    marginLeft: 8,
  },
  separator: {
    width: 4,
    height: 4,
    borderRadius: 2,
    backgroundColor: 'rgba(255, 255, 255, 0.2)',
    marginHorizontal: 12,
  },
  emptyContainer: {
    alignItems: 'center',
    justifyContent: 'center',
    marginTop: theme.spacing.xxl * 2,
    padding: theme.spacing.xl,
  },
  emptyIcon: {
    marginBottom: theme.spacing.lg,
    opacity: 0.5,
  },
  emptyTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: theme.colors.white,
    marginBottom: 8,
  },
  emptySubtitle: {
    fontSize: 14,
    color: theme.colors.slate,
    textAlign: 'center',
  },
});

export default HistoryScreen;
