import React, { useCallback, useState } from 'react';
import { ActivityIndicator, FlatList, RefreshControl, SafeAreaView, StyleSheet, Text, View } from 'react-native';
import { useFocusEffect } from '@react-navigation/native';
import { FarmersMKApi } from '../api/FarmersMKApi';
import ProductCard from '../components/ProductCard';
import { colors } from '../theme';

export default function MarketplaceScreen() {
  const [products, setProducts] = useState([]);
  const [status, setStatus] = useState({ loading: true, message: '' });
  const [refreshing, setRefreshing] = useState(false);

  const loadProducts = async () => {
    try {
      setStatus({ loading: true, message: '' });
      const items = await FarmersMKApi.getProducts();
      setProducts(items);
      setStatus({ loading: false, message: '' });
    } catch (error) {
      setStatus({ loading: false, message: error.message });
    }
  };

  useFocusEffect(
    useCallback(() => {
      loadProducts();
    }, [])
  );

  const onRefresh = async () => {
    setRefreshing(true);
    await loadProducts();
    setRefreshing(false);
  };

  if (status.loading) {
    return (
      <SafeAreaView style={styles.centered}>
        <ActivityIndicator size="large" color={colors.brandDeep} />
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.safeArea}>
      {status.message ? <Text style={styles.error}>{status.message}</Text> : null}
      <FlatList
        contentContainerStyle={styles.list}
        data={products}
        keyExtractor={(item, index) => `${item.id || index}`}
        renderItem={({ item }) => <ProductCard product={item} />}
        ListEmptyComponent={<Text style={styles.empty}>No products found.</Text>}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} />}
      />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: colors.background
  },
  centered: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: colors.background
  },
  list: {
    padding: 14,
    gap: 10
  },
  error: {
    margin: 14,
    backgroundColor: colors.errorBg,
    color: colors.errorText,
    borderRadius: 10,
    padding: 10,
    fontWeight: '600'
  },
  empty: {
    color: colors.muted,
    textAlign: 'center',
    marginTop: 30
  }
});
