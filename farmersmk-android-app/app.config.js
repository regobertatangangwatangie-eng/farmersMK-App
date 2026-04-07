import appJson from './app.json';

const baseApiUrl = process.env.EXPO_PUBLIC_API_BASE_URL || 'http://10.0.2.2:8080';

export default {
  expo: {
    ...appJson.expo,
    android: {
      ...appJson.expo.android,
      adaptiveIcon: {
        ...appJson.expo.android?.adaptiveIcon,
        backgroundColor: '#0E9F6E'
      }
    },
    splash: {
      resizeMode: 'contain',
      backgroundColor: '#0E9F6E'
    },
    extra: {
      ...appJson.expo.extra,
      apiBaseUrl: baseApiUrl,
      eas: {
        ...appJson.expo.extra?.eas,
        projectId: 'dda3855f-a7de-480e-acce-d0288078b6b9'
      }
    },
    owner: 'regobert2004'
  }
};
