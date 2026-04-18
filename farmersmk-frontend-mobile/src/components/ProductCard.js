import React from 'react';
import { View, Text, Image } from 'react-native';

export default function ProductCard({ product }) {
  return (
    <View style={{
      padding: 15,
      marginBottom: 10,
      borderWidth: 1,
      borderRadius: 8,
      alignItems: 'center'
    }}>
      {product.imageUrl && (
        <Image
          source={{ uri: product.imageUrl }}
          style={{ width: 120, height: 120, borderRadius: 8, marginBottom: 8 }}
          resizeMode="cover"
        />
      )}
      <Text style={{ fontSize: 18 }}>{product.name}</Text>
      <Text>{product.description}</Text>
      <Text>Price: {product.price} XAF</Text>
    </View>
  );
}