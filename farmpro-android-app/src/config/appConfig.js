import Constants from 'expo-constants';
import { Platform } from 'react-native';

const fallbackBaseUrl = Platform.OS === 'android' ? 'http://10.0.2.2:8080' : 'http://localhost:8080';
const configuredBaseUrl =
  process.env.EXPO_PUBLIC_API_BASE_URL ||
  Constants?.expoConfig?.extra?.apiBaseUrl ||
  fallbackBaseUrl;

export const APP_CONFIG = {
  appName: 'FARMERPRO',
  baseUrl: configuredBaseUrl.replace(/\/$/, '')
};
