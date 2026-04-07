import React from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { colors } from '../theme';

export default function ProductCard({ product }) {
  return (
    <View style={styles.card}>
      <Text style={styles.title}>{product.name || 'Unnamed Product'}</Text>
      <Text style={styles.meta}>Price: ${product.price ?? 'N/A'}</Text>
      <Text style={styles.meta}>ID: {product.id ?? 'N/A'}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  card: {
    backgroundColor: '#fff',
    borderWidth: 1,
    borderColor: colors.border,
    borderRadius: 12,
    padding: 12
  },
  title: {
    fontSize: 16,
    fontWeight: '800',
    color: colors.text,
    marginBottom: 4
  },
  meta: {
    color: colors.muted
  }
});