import { initializeApp } from 'firebase/app';
import { getFirestore } from 'firebase/firestore';
import { initializeAuth, getReactNativePersistence } from 'firebase/auth';
import AsyncStorage from '@react-native-async-storage/async-storage';

const firebaseConfig = {
  apiKey: "AIzaSyCUIrl7JuEObajXDARHNN96ex3n_LzuKOM",
  authDomain: "sos-safety-app-9ad4.firebaseapp.com",
  projectId: "sos-safety-app-9ad4",
  storageBucket: "sos-safety-app-9ad4.firebasestorage.app",
  messagingSenderId: "219689822078",
  appId: "1:219689822078:web:faddc5203191022d18352f"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

// Initialize Firebase Auth with AsyncStorage persistence
const auth = initializeAuth(app, {
  persistence: getReactNativePersistence(AsyncStorage)
});

export { db, auth };
