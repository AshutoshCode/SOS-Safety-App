import React, { useState, useEffect } from 'react';
import { db, auth } from '../services/firebase';
import { collection, query, onSnapshot, addDoc, deleteDoc, doc, serverTimestamp } from 'firebase/firestore';

export const useContacts = () => {
  const [contacts, setContacts] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    if (!auth.currentUser) {
      setIsLoading(false);
      return;
    }

    const q = query(collection(db, `users/${auth.currentUser.uid}/contacts`));
    
    const unsubscribe = onSnapshot(q, (snapshot) => {
      const contactList = snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));
      setContacts(contactList);
      setIsLoading(false);
    }, (err) => {
      console.error(err);
      setError('Failed to fetch contacts');
      setIsLoading(false);
    });

    return () => unsubscribe();
  }, [auth.currentUser]);

  const addContact = async (name, phoneNumber) => {
    try {
      if (!auth.currentUser) {
        setError('User not authenticated');
        return;
      }
      setIsLoading(true);
      await addDoc(collection(db, `users/${auth.currentUser.uid}/contacts`), {
        name,
        phoneNumber,
        createdAt: serverTimestamp()
      });
      setIsLoading(false);
    } catch (err) {
      console.error(err);
      setError('Failed to add contact');
      setIsLoading(false);
    }
  };

  const removeContact = async (contactId) => {
    try {
      if (!auth.currentUser) {
        setError('User not authenticated');
        return;
      }
      setIsLoading(true);
      await deleteDoc(doc(db, `users/${auth.currentUser.uid}/contacts`, contactId));
      setIsLoading(false);
    } catch (err) {
      console.error(err);
      setError('Failed to remove contact');
      setIsLoading(false);
    }
  };

  return {
    contacts,
    isLoading,
    error,
    addContact,
    removeContact,
    clearError: () => setError(null)
  };
};
