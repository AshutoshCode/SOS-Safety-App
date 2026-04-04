import React from 'react';
import { StyleSheet, View, Text, TouchableOpacity, Animated } from 'react-native';
import { theme } from '../theme/theme';
import * as Haptics from 'expo-haptics';

const PremiumSOSButton = ({ onPress, onLongPress, isLoading }) => {
  const pulseScale = new Animated.Value(1);

  React.useEffect(() => {
    Animated.loop(
      Animated.sequence([
        Animated.timing(pulseScale, {
          toValue: 1.1,
          duration: 1000,
          useNativeDriver: true,
        }),
        Animated.timing(pulseScale, {
          toValue: 1.0,
          duration: 1000,
          useNativeDriver: true,
        }),
      ])
    ).start();
  }, []);

  const handleLongPress = () => {
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Warning);
    onLongPress();
  };

  return (
    <View style={styles.container}>
      <Animated.View style={[styles.pulseCircle, { transform: [{ scale: pulseScale }] }]} />
      <TouchableOpacity
        style={[styles.button, isLoading && styles.disabled]}
        onLongPress={handleLongPress}
        onPress={() => Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light)}
        activeOpacity={0.8}
        disabled={isLoading}
      >
        <Text style={styles.text}>{isLoading ? '...' : 'SOS'}</Text>
        <Text style={styles.subtext}>{isLoading ? 'TRIGGERING' : 'HOLD TO TRIGGER'}</Text>
      </TouchableOpacity>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    alignItems: 'center',
    justifyContent: 'center',
    marginVertical: theme.spacing.xl,
  },
  pulseCircle: {
    position: 'absolute',
    width: 200,
    height: 200,
    borderRadius: 100,
    backgroundColor: theme.colors.emergency,
    opacity: 0.15,
  },
  button: {
    width: 180,
    height: 180,
    borderRadius: 90,
    backgroundColor: theme.colors.emergency,
    alignItems: 'center',
    justifyContent: 'center',
    shadowColor: theme.colors.emergency,
    shadowOffset: { width: 0, height: 10 },
    shadowOpacity: 0.4,
    shadowRadius: 20,
    elevation: 10,
  },
  disabled: {
    opacity: 0.7,
  },
  text: {
    fontSize: 56,
    fontWeight: '900',
    color: theme.colors.white,
    letterSpacing: 2,
  },
  subtext: {
    fontSize: 10,
    color: theme.colors.white,
    marginTop: 8,
    fontWeight: 'bold',
  },
});

export default PremiumSOSButton;
