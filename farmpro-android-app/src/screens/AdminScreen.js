import React, { useState } from 'react';
import { Pressable, SafeAreaView, ScrollView, StyleSheet, Text, View } from 'react-native';
import { farmproApi } from '../api/farmproApi';
import { useAuth } from '../context/AuthContext';
import { colors } from '../theme';

export default function AdminScreen() {
  const { session } = useAuth();
  const [users, setUsers] = useState([]);
  const [status, setStatus] = useState('Admin tools are ready.');
  const [loading, setLoading] = useState(false);

  const isAdmin = session?.user?.role === 'ADMIN';

  const loadUsers = async () => {
    if (!session?.token) {
      setStatus('Missing token. Sign in again.');
      return;
    }

    setLoading(true);
    try {
      const list = await farmproApi.getProtectedUsers(session.token);
      setUsers(list);
      setStatus(`Loaded ${list.length} users.`);
    } catch (error) {
      setStatus(error.message);
      setUsers([]);
    } finally {
      setLoading(false);
    }
  };

  if (!isAdmin) {
    return (
      <SafeAreaView style={styles.safeArea}>
        <View style={styles.lockedCard}>
          <Text style={styles.lockedTitle}>Admin access required</Text>
          <Text style={styles.lockedText}>
            This section is protected. Sign in with an ADMIN account to manage protected resources.
          </Text>
        </View>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.safeArea}>
      <ScrollView contentContainerStyle={styles.content}>
        <Text style={styles.title}>Admin Control Center</Text>

        <Pressable style={styles.button} onPress={loadUsers} disabled={loading}>
          <Text style={styles.buttonText}>{loading ? 'Loading...' : 'Load Protected Users'}</Text>
        </Pressable>

        <Text style={styles.status}>{status}</Text>

        {users.map((item) => (
          <View style={styles.userRow} key={item.id || item.email}>
            <Text style={styles.userName}>{item.name}</Text>
            <Text style={styles.userMeta}>{item.email}</Text>
            <Text style={styles.userMeta}>{item.role}</Text>
          </View>
        ))}
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
    gap: 10
  },
  title: {
    fontSize: 20,
    color: colors.text,
    fontWeight: '800'
  },
  button: {
    backgroundColor: '#1B3D8A',
    borderRadius: 10,
    paddingVertical: 10,
    alignItems: 'center'
  },
  buttonText: {
    color: '#fff',
    fontWeight: '700'
  },
  status: {
    backgroundColor: '#fff',
    borderWidth: 1,
    borderColor: colors.border,
    borderRadius: 10,
    padding: 10,
    color: colors.text
  },
  userRow: {
    backgroundColor: '#fff',
    borderWidth: 1,
    borderColor: colors.border,
    borderRadius: 10,
    padding: 10,
    gap: 4
  },
  userName: {
    color: colors.text,
    fontWeight: '800'
  },
  userMeta: {
    color: colors.muted
  },
  lockedCard: {
    margin: 16,
    padding: 14,
    borderRadius: 12,
    backgroundColor: colors.warningBg,
    borderWidth: 1,
    borderColor: '#F4C96B',
    gap: 8
  },
  lockedTitle: {
    color: colors.warningText,
    fontWeight: '800',
    fontSize: 18
  },
  lockedText: {
    color: '#6B4A00'
  }
});