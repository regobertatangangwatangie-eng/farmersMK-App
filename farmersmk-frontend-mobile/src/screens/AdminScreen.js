import React, { useState } from 'react';
import { View, TextInput, Button } from 'react-native';
import { addProduct } from '../api/api';

export default function AdminScreen() {
  const [name, setName] = useState('');
  const [price, setPrice] = useState('');

  const handleAdd = () => {
    addProduct({ name, price: parseFloat(price) })
      .then(() => {
        setName('');
        setPrice('');
        alert('Product added!');
      })
      .catch(err => console.log(err));
  };

  return (
    <View style={{ padding: 20 }}>
      <TextInput
        placeholder="Product Name"
        value={name}
        onChangeText={setName}
        style={{ borderWidth: 1, marginBottom: 10 }}
      />

      <TextInput
        placeholder="Price"
        value={price}
        onChangeText={setPrice}
        keyboardType="numeric"
        style={{ borderWidth: 1, marginBottom: 10 }}
      />

      <Button title="Add Product" onPress={handleAdd} />
    </View>
  );
}