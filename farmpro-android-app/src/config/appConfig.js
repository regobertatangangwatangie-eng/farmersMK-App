import Constants from 'expo-constants';
import { Platform } from 'react-native';

const fallbackBaseUrl = Platform.OS === 'android' ? 'http://10.0.2.2' : 'http://localhost';

export const APP_CONFIG = {
  appName: 'FARMERPRO',
  baseUrl: Constants?.expoConfig?.extra?.apiBaseUrl || fallbackBaseUrl
};
