import React, { createContext, useCallback, useContext, useEffect, useMemo, useState } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { FarmersMKApi } from '../api/FarmersMKApi';

const SESSION_KEY = 'FarmersMK_mobile_session';

const AuthContext = createContext(undefined);

export const AuthProvider = ({ children }) => {
  const [session, setSession] = useState(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const bootstrap = async () => {
      try {
        const saved = await AsyncStorage.getItem(SESSION_KEY);
        if (saved) {
          setSession(JSON.parse(saved));
        }
      } finally {
        setIsLoading(false);
      }
    };

    bootstrap();
  }, []);

  const saveSession = useCallback(async (payload) => {
    await AsyncStorage.setItem(SESSION_KEY, JSON.stringify(payload));
    setSession(payload);
  }, []);

  const signIn = useCallback(async ({ email, password }) => {
    const result = await FarmersMKApi.login({ email, password });
    const nextSession = {
      token: result.token,
      user: {
        id: result.userId,
        name: result.name,
        email: result.email,
        role: (result.role || 'USER').toUpperCase()
      }
    };
    await saveSession(nextSession);
    return nextSession;
  }, [saveSession]);

  const signUp = useCallback(async ({ name, email, role, password }) => {
    const result = await FarmersMKApi.register({ name, email, role, password });
    const nextSession = {
      token: result.token,
      user: {
        id: result.userId,
        name: result.name,
        email: result.email,
        role: (result.role || 'USER').toUpperCase()
      }
    };
    await saveSession(nextSession);
    return nextSession;
  }, [saveSession]);

  const signOut = useCallback(async () => {
    await AsyncStorage.removeItem(SESSION_KEY);
    setSession(null);
  }, []);

  const value = useMemo(() => ({
    isLoading,
    session,
    signIn,
    signUp,
    signOut
  }), [isLoading, session, signIn, signUp, signOut]);

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used inside AuthProvider.');
  }
  return context;
};
