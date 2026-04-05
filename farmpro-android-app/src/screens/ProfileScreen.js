import React from 'react';
import { Pressable, SafeAreaView, StyleSheet, Text, View } from 'react-native';
import { useAuth } from '../context/AuthContext';
import { colors } from '../theme';

export default function ProfileScreen() {
  const { session, signOut } = useAuth();

  return (
    <SafeAreaView style={styles.safeArea}>
      <View style={styles.card}>
        <Text style={styles.title}>Account</Text>
        <Text style={styles.line}>Name: {session?.user?.name}</Text>
        <Text style={styles.line}>Email: {session?.user?.email}</Text>
        <Text style={styles.line}>Role: {session?.user?.role}</Text>

        <Pressable style={styles.button} onPress={signOut}>
          <Text style={styles.buttonText}>Sign Out</Text>
        </Pressable>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: colors.background,
    padding: 16
  },
  card: {
    backgroundColor: '#fff',
    borderWidth: 1,
    borderColor: colors.border,
    borderRadius: 14,
    padding: 14
  },
  title: {
    fontSize: 20,
    fontWeight: '800',
    color: colors.text,
    marginBottom: 10
  },
  line: {
    color: colors.text,
    marginBottom: 6
  },
  button: {
    marginTop: 12,
    backgroundColor: '#8C2D2D',
    borderRadius: 10,
    alignItems: 'center',
    paddingVertical: 10
  },
  buttonText: {
    color: '#fff',
    fontWeight: '700'
  }
});
