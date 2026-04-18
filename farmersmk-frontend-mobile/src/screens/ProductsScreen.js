import React, { useEffect, useState } from 'react';
import { View, FlatList } from 'react-native';
import { getProducts } from '../api/api';
import ProductCard from '../components/ProductCard';

export default function ProductsScreen() {
  const [products, setProducts] = useState([]);

  useEffect(() => {
    getProducts()
      .then(res => {
        if (Array.isArray(res.data) && res.data.length > 0) {
          setProducts(res.data);
        } else {
          // Mock products for demo
          setProducts([
            {
              id: 1,
              name: 'ANAG',
              description: 'Extraordinary pasteurized palm wine',
              price: 500,
              imageUrl: 'https://raw.githubusercontent.com/regobertatangangwatangie-eng/farmersMK-App/master/docs/anag-palmwine-demo.jpg'
            },
            {
              id: 2,
              name: 'Palm Oil',
              description: 'Natural palm oil',
              price: 1000,
              imageUrl: 'https://raw.githubusercontent.com/regobertatangangwatangie-eng/farmersMK-App/master/docs/mul-palmoil-demo.jpg'
            }
          ]);
        }
      })
      .catch(err => {
        // On error, show mock products for demo
        setProducts([
          {
            id: 1,
            name: 'ANAG',
            description: 'Extraordinary pasteurized palm wine',
            price: 500,
            imageUrl: 'https://raw.githubusercontent.com/regobertatangangwatangie-eng/farmersMK-App/master/docs/anag-palmwine-demo.jpg'
          },
          {
            id: 2,
            name: 'Palm Oil',
            description: 'Natural palm oil',
            price: 1000,
            imageUrl: 'https://raw.githubusercontent.com/regobertatangangwatangie-eng/farmersMK-App/master/docs/mul-palmoil-demo.jpg'
          }
        ]);
      });
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