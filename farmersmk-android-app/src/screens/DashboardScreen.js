import React from 'react';
import { Linking, Pressable, SafeAreaView, ScrollView, StyleSheet, Text, View } from 'react-native';
import { useAuth } from '../context/AuthContext';
import { APP_CONFIG } from '../config/appConfig';
import { colors } from '../theme';

const quickActions = [
  { label: 'Marketplace', url: '/products' },
  { label: 'Gateway', url: '/gateway' },
  { label: 'Realtime', url: '/ws' },
  { label: 'Notifications', url: '/api/notifications' }
];

export default function DashboardScreen() {
  const { session } = useAuth();

  const openUrl = async (path) => {
    const target = `${APP_CONFIG.baseUrl}${path}`;
    await Linking.openURL(target);
  };

  return (
    <SafeAreaView style={styles.safeArea}>
      <ScrollView contentContainerStyle={styles.content}>
        <View style={styles.hero}>
          <Text style={styles.heroTitle}>Welcome, {session?.user?.name || 'User'}</Text>
          <Text style={styles.heroSubtitle}>Role: {session?.user?.role || 'USER'}</Text>
          <Text style={styles.heroCopy}>
            Use this Android client to manage farmersmk marketplace, payments, social integrations,
            and secured admin operations from one app.
          </Text>
        </View>

        <Text style={styles.sectionTitle}>Quick Actions</Text>
        <View style={styles.grid}>
          {quickActions.map((item) => (
            <Pressable key={item.label} style={styles.card} onPress={() => openUrl(item.url)}>
              <Text style={styles.cardTitle}>{item.label}</Text>
              <Text style={styles.cardText}>{`${APP_CONFIG.baseUrl}${item.url}`}</Text>
            </Pressable>
          ))}
        </View>

        <Text style={styles.sectionTitle}>Mobile App Quality Checklist</Text>
        <View style={styles.checklist}>
          <Text style={styles.checkItem}>- Structured screens and navigation</Text>
          <Text style={styles.checkItem}>- JWT auth and persisted session</Text>
          <Text style={styles.checkItem}>- Role-aware admin controls</Text>
          <Text style={styles.checkItem}>- API integration to farmersmk services</Text>
          <Text style={styles.checkItem}>- Android package metadata ready</Text>
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
    padding: 16,
    gap: 14
  },
  hero: {
    backgroundColor: '#0D875E',
    borderRadius: 16,
    padding: 16
  },
  heroTitle: {
    color: '#fff',
    fontWeight: '800',
    fontSize: 22
  },
  heroSubtitle: {
    color: '#D6FCEB',
    marginTop: 6,
    fontWeight: '700'
  },
  heroCopy: {
    color: '#E8FFF5',
    marginTop: 10,
    lineHeight: 20
  },
  sectionTitle: {
    color: colors.text,
    fontSize: 18,
    fontWeight: '800'
  },
  grid: {
    gap: 10
  },
  card: {
    backgroundColor: '#fff',
    borderWidth: 1,
    borderColor: colors.border,
    borderRadius: 12,
    padding: 12
  },
  cardTitle: {
    color: colors.text,
    fontWeight: '800'
  },
  cardText: {
    color: colors.muted,
    marginTop: 4
  },
  checklist: {
    backgroundColor: '#fff',
    borderWidth: 1,
    borderColor: colors.border,
    borderRadius: 12,
    padding: 12,
    gap: 8
  },
  checkItem: {
    color: colors.text
  }
});
