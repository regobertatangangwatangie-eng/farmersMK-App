import React, { useState } from 'react';
import {
  KeyboardAvoidingView,
  Platform,
  Pressable,
  SafeAreaView,
  StyleSheet,
  Text,
  TextInput,
  View
} from 'react-native';
import { useAuth } from '../context/AuthContext';
import { colors } from '../theme';

const roles = ['FARMER', 'BUYER', 'AGRO_PARTNER', 'ADMIN'];

export default function AuthScreen() {
  const { signIn, signUp } = useAuth();
  const [mode, setMode] = useState('signin');
  const [form, setForm] = useState({ name: '', email: '', password: '', role: 'FARMER' });
  const [status, setStatus] = useState({ type: '', message: '', loading: false });

  const isSignup = mode === 'signup';

  const update = (field, value) => {
    setForm((prev) => ({ ...prev, [field]: value }));
  };

  const submit = async () => {
    if (!form.email || !form.password || (isSignup && !form.name)) {
      setStatus({ type: 'error', message: 'Please fill all required fields.', loading: false });
      return;
    }

    setStatus({ type: '', message: '', loading: true });
    try {
      if (isSignup) {
        await signUp({
          name: form.name.trim(),
          email: form.email.trim().toLowerCase(),
          role: form.role,
          password: form.password
        });
      } else {
        await signIn({
          email: form.email.trim().toLowerCase(),
          password: form.password
        });
      }
      setStatus({ type: 'success', message: 'Authentication successful.', loading: false });
    } catch (error) {
      setStatus({ type: 'error', message: error.message, loading: false });
    }
  };

  return (
    <SafeAreaView style={styles.safeArea}>
      <KeyboardAvoidingView
        style={styles.container}
        behavior={Platform.OS === 'ios' ? 'padding' : undefined}
      >
        <Text style={styles.title}>FARMERPRO Mobile</Text>
        <Text style={styles.subtitle}>Production-ready Android app for marketplace and services.</Text>

        <View style={styles.modeRow}>
          <Pressable style={[styles.modeChip, mode === 'signin' && styles.modeChipActive]} onPress={() => setMode('signin')}>
            <Text style={[styles.modeText, mode === 'signin' && styles.modeTextActive]}>Sign In</Text>
          </Pressable>
          <Pressable style={[styles.modeChip, mode === 'signup' && styles.modeChipActive]} onPress={() => setMode('signup')}>
            <Text style={[styles.modeText, mode === 'signup' && styles.modeTextActive]}>Create Account</Text>
          </Pressable>
        </View>

        {isSignup ? (
          <TextInput
            style={styles.input}
            placeholder="Full name"
            value={form.name}
            onChangeText={(value) => update('name', value)}
            placeholderTextColor={colors.muted}
          />
        ) : null}

        <TextInput
          style={styles.input}
          placeholder="Email"
          autoCapitalize="none"
          value={form.email}
          onChangeText={(value) => update('email', value)}
          placeholderTextColor={colors.muted}
        />

        <TextInput
          style={styles.input}
          placeholder="Password"
          secureTextEntry
          value={form.password}
          onChangeText={(value) => update('password', value)}
          placeholderTextColor={colors.muted}
        />

        {isSignup ? (
          <View style={styles.roleGrid}>
            {roles.map((roleItem) => (
              <Pressable
                key={roleItem}
                style={[styles.roleChip, form.role === roleItem && styles.roleChipActive]}
                onPress={() => update('role', roleItem)}
              >
                <Text style={[styles.roleText, form.role === roleItem && styles.roleTextActive]}>{roleItem}</Text>
              </Pressable>
            ))}
          </View>
        ) : null}

        {status.message ? (
          <Text style={[styles.status, status.type === 'error' ? styles.error : styles.success]}>
            {status.message}
          </Text>
        ) : null}

        <Pressable style={styles.submitButton} onPress={submit} disabled={status.loading}>
          <Text style={styles.submitText}>{status.loading ? 'Please wait...' : isSignup ? 'Sign Up' : 'Sign In'}</Text>
        </Pressable>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: colors.background
  },
  container: {
    flex: 1,
    paddingHorizontal: 18,
    justifyContent: 'center'
  },
  title: {
    fontSize: 30,
    fontWeight: '800',
    color: colors.brandDeep,
    marginBottom: 6
  },
  subtitle: {
    color: colors.muted,
    marginBottom: 20
  },
  modeRow: {
    flexDirection: 'row',
    marginBottom: 12,
    gap: 8
  },
  modeChip: {
    borderWidth: 1,
    borderColor: colors.border,
    borderRadius: 999,
    paddingVertical: 8,
    paddingHorizontal: 14,
    backgroundColor: colors.surface
  },
  modeChipActive: {
    backgroundColor: colors.brand,
    borderColor: colors.brand
  },
  modeText: {
    color: colors.text,
    fontWeight: '600'
  },
  modeTextActive: {
    color: '#fff'
  },
  input: {
    borderWidth: 1,
    borderColor: colors.border,
    borderRadius: 10,
    backgroundColor: '#fff',
    paddingHorizontal: 12,
    paddingVertical: 11,
    marginBottom: 10,
    color: colors.text
  },
  roleGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
    marginBottom: 10
  },
  roleChip: {
    borderWidth: 1,
    borderColor: colors.border,
    borderRadius: 999,
    paddingVertical: 7,
    paddingHorizontal: 11,
    backgroundColor: '#fff'
  },
  roleChipActive: {
    backgroundColor: '#ECFDF3',
    borderColor: colors.brand
  },
  roleText: {
    color: colors.muted,
    fontSize: 12,
    fontWeight: '700'
  },
  roleTextActive: {
    color: colors.brandDeep
  },
  status: {
    borderRadius: 10,
    paddingVertical: 9,
    paddingHorizontal: 12,
    marginBottom: 10,
    fontWeight: '600'
  },
  error: {
    color: colors.errorText,
    backgroundColor: colors.errorBg
  },
  success: {
    color: colors.brandDeep,
    backgroundColor: '#E5FFF1'
  },
  submitButton: {
    backgroundColor: colors.brand,
    borderRadius: 12,
    paddingVertical: 12,
    alignItems: 'center'
  },
  submitText: {
    color: '#fff',
    fontWeight: '800'
  }
});
