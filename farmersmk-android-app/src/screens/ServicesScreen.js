import React, { useState } from 'react';
import { Pressable, SafeAreaView, ScrollView, StyleSheet, Text, View } from 'react-native';
import { FarmersMKApi } from '../api/farmersmkApi';
import { colors } from '../theme';

const serviceGroups = [
  {
    title: 'Core Platform',
    items: ['API Gateway', 'User Service', 'Admin Service', 'Marketplace Service']
  },
  {
    title: 'Payments',
    items: ['Mastercard', 'VISA', 'MTN Mobile Money', 'Orange Money', 'Crypto Wallet']
  },
  {
    title: 'Engagement',
    items: ['Post Service', 'Notifications', 'Realtime Service', 'Facebook', 'Instagram', 'Twitter']
  }
];

export default function ServicesScreen() {
  const [status, setStatus] = useState('Tap to run a realtime service connectivity check.');

  const runRealtimeCheck = async () => {
    try {
      const result = await FarmersMKApi.checkRealtime();
      setStatus(`Realtime service reachable: ${typeof result === 'string' ? result : 'OK'}`);
    } catch (error) {
      setStatus(`Realtime check failed: ${error.message}`);
    }
  };

  return (
    <SafeAreaView style={styles.safeArea}>
      <ScrollView contentContainerStyle={styles.content}>
        {serviceGroups.map((group) => (
          <View key={group.title} style={styles.groupCard}>
            <Text style={styles.groupTitle}>{group.title}</Text>
            {group.items.map((item) => (
              <Text key={item} style={styles.itemText}>- {item}</Text>
            ))}
          </View>
        ))}

        <View style={styles.groupCard}>
          <Text style={styles.groupTitle}>Connectivity Test</Text>
          <Pressable style={styles.button} onPress={runRealtimeCheck}>
            <Text style={styles.buttonText}>Check Realtime Service</Text>
          </Pressable>
          <Text style={styles.status}>{status}</Text>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: colors.background
  },
  content: {
    padding: 14,
    gap: 12
  },
  groupCard: {
    backgroundColor: '#fff',
    borderWidth: 1,
    borderColor: colors.border,
    borderRadius: 12,
    padding: 12,
    gap: 5
  },
  groupTitle: {
    fontSize: 16,
    fontWeight: '800',
    color: colors.text,
    marginBottom: 4
  },
  itemText: {
    color: colors.muted
  },
  button: {
    marginTop: 8,
    backgroundColor: colors.brand,
    borderRadius: 10,
    alignItems: 'center',
    paddingVertical: 10
  },
  buttonText: {
    color: '#fff',
    fontWeight: '700'
  },
  status: {
    marginTop: 8,
    color: colors.text
  }
});
