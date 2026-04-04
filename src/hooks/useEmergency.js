import React, { useState, useEffect } from 'react';
import * as Location from 'expo-location';
import * as SMS from 'expo-sms';
import { db, auth } from '../services/firebase';
import { collection, addDoc, serverTimestamp, updateDoc, doc, getDocs, query } from 'firebase/firestore';
import * as Haptics from 'expo-haptics';

export const useEmergency = () => {
  const [activeAlert, setActiveAlert] = useState(null);
  const [isLoading, setIsLoading] = useState(false);
  const [isTracking, setIsTracking] = useState(false);
  const [isRecording, setIsRecording] = useState(false);
  const [location, setLocation] = useState(null);
  const [error, setError] = useState(null);

  const triggerSOS = async () => {
    try {
      if (!auth.currentUser) {
        setError('User not authenticated');
        return;
      }

      setIsLoading(true);
      setError(null);
      await Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);

      // 1. Get current location immediately
      let { status } = await Location.requestForegroundPermissionsAsync();
      if (status !== 'granted') {
        setError('Location permission denied');
        setIsLoading(false);
        return;
      }
      
      let initialLocation = await Location.getCurrentPositionAsync({});
      setLocation(initialLocation);

      // 2. Fetch real emergency contacts from Firestore
      const contactsSnapshot = await getDocs(query(collection(db, `users/${auth.currentUser.uid}/contacts`)));
      const contactNumbers = contactsSnapshot.docs.map(doc => doc.data().phoneNumber).filter(num => !!num);

      if (contactNumbers.length === 0) {
        setError('No emergency contacts found. Please add some first.');
        setIsLoading(false);
        return;
      }

      // 3. Send Native SMS to all contacts
      const isAvailable = await SMS.isAvailableAsync();
      if (isAvailable) {
        const message = `EMERGENCY SOS! I need help. My current location: https://maps.google.com/?q=${initialLocation.coords.latitude},${initialLocation.coords.longitude}`;
        await SMS.sendSMSAsync(contactNumbers, message);
      }

      // 4. Create Alert in Firestore for live tracking
      const alertRef = await addDoc(collection(db, `users/${auth.currentUser.uid}/alerts`), {
        status: 'active',
        triggerType: 'sos',
        createdAt: serverTimestamp(),
        lastLatitude: initialLocation.coords.latitude,
        lastLongitude: initialLocation.coords.longitude,
      });

      setActiveAlert({ id: alertRef.id, ...initialLocation });
      setIsTracking(true);
      
      setIsLoading(false);
    } catch (err) {
      console.error(err);
      setError('Failed to trigger SOS');
      setIsLoading(false);
    }
  };

  const resolveAlert = async () => {
    if (!activeAlert || !auth.currentUser) return;
    try {
      setIsLoading(true);
      const alertDoc = doc(db, `users/${auth.currentUser.uid}/alerts`, activeAlert.id);
      await updateDoc(alertDoc, {
        status: 'resolved',
        resolvedAt: serverTimestamp(),
      });
      setActiveAlert(null);
      setIsTracking(false);
      setIsRecording(false);
      setIsLoading(false);
    } catch (err) {
      setError('Failed to resolve alert');
      setIsLoading(false);
    }
  };

  // Continuous tracking logic
  useEffect(() => {
    let subscription;
    if (isTracking && activeAlert && auth.currentUser) {
      subscription = Location.watchPositionAsync(
        { accuracy: Location.Accuracy.High, distanceInterval: 10 },
        (newLoc) => {
          if (!auth.currentUser) return;
          setLocation(newLoc);
          const alertDoc = doc(db, `users/${auth.currentUser.uid}/alerts`, activeAlert.id);
          updateDoc(alertDoc, {
            lastLatitude: newLoc.coords.latitude,
            lastLongitude: newLoc.coords.longitude,
          });
        }
      );
    }
    return () => subscription?.remove?.();
  }, [isTracking, activeAlert]);

  return {
    triggerSOS,
    resolveAlert,
    activeAlert,
    isLoading,
    isTracking,
    isRecording,
    location,
    error,
    clearError: () => setError(null),
  };
};
