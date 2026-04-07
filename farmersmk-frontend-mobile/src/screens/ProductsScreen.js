import React, { useEffect, useState } from 'react';
import { View, FlatList } from 'react-native';
import { getProducts } from '../api/api';
import ProductCard from '../components/ProductCard';

export default function ProductsScreen() {
  const [products, setProducts] = useState([]);

  useEffect(() => {
    getProducts()
      .then(res => setProducts(res.data))
      .catch(err => console.log(err));
  }, []);

  return (
    <View style={{ padding: 10 }}>
      <FlatList
        data={products}
        keyExtractor={(item) => item.id.toString()}
        renderItem={({ item }) => <ProductCard product={item} />}
      />
    </View>
  );
}