import React from 'react';
import { View, Text } from 'react-native';

export default function ProductCard({ product }) {
  return (
    <View style={{
      padding: 15,
      marginBottom: 10,
      borderWidth: 1,
      borderRadius: 8
    }}>
      <Text style={{ fontSize: 18 }}>{product.name}</Text>
      <Text>Price: ${product.price}</Text>
    </View>
  );
}