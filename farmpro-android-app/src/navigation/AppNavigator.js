import React from 'react';
import { ActivityIndicator, Text, View } from 'react-native';
import { NavigationContainer } from '@react-navigation/native';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { useAuth } from '../context/AuthContext';
import AuthScreen from '../screens/AuthScreen';
import DashboardScreen from '../screens/DashboardScreen';
import MarketplaceScreen from '../screens/MarketplaceScreen';
import ServicesScreen from '../screens/ServicesScreen';
import AdminScreen from '../screens/AdminScreen';
import ProfileScreen from '../screens/ProfileScreen';
import { colors } from '../theme';

const Tabs = createBottomTabNavigator();

const LoadingScreen = () => (
  <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center', backgroundColor: colors.background }}>
    <ActivityIndicator size="large" color={colors.brandDeep} />
    <Text style={{ marginTop: 12, color: colors.muted }}>Starting FARMERPRO Mobile...</Text>
  </View>
);

export default function AppNavigator() {
  const { isLoading, session } = useAuth();

  if (isLoading) {
    return <LoadingScreen />;
  }

  return (
    <NavigationContainer>
      {!session ? (
        <AuthScreen />
      ) : (
        <Tabs.Navigator
          screenOptions={{
            headerStyle: { backgroundColor: colors.brand },
            headerTintColor: '#ffffff',
            tabBarActiveTintColor: colors.brand,
            tabBarInactiveTintColor: '#6b7280'
          }}
        >
          <Tabs.Screen name="Home" component={DashboardScreen} />
          <Tabs.Screen name="Marketplace" component={MarketplaceScreen} />
          <Tabs.Screen name="Services" component={ServicesScreen} />
          <Tabs.Screen name="Admin" component={AdminScreen} />
          <Tabs.Screen name="Profile" component={ProfileScreen} />
        </Tabs.Navigator>
      )}
    </NavigationContainer>
  );
}
