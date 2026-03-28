import React from 'react';
import { View, Text, Button } from 'react-native';
import HomeScreen from './screens/HomeScreen';
import ProductsScreen from './screens/ProductsScreen';
import AdminScreen from './screens/AdminScreen';

export default function App() {
  const [screen, setScreen] = React.useState('home');

  const renderScreen = () => {
    if (screen === 'products') return <ProductsScreen />;
    if (screen === 'admin') return <AdminScreen />;
    return <HomeScreen />;
  };

  return (
    <View style={{ flex: 1, paddingTop: 40 }}>
      <View style={{ flexDirection: 'row', justifyContent: 'space-around' }}>
        <Button title="Home" onPress={() => setScreen('home')} />
        <Button title="Products" onPress={() => setScreen('products')} />
        <Button title="Admin" onPress={() => setScreen('admin')} />
      </View>

      {renderScreen()}
    </View>
  );
}