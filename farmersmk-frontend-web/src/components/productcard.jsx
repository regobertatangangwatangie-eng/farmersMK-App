import React from 'react';

const ProductCard = ({ product }) => {
  return (
    <div style={{ border: '1px solid #ddd', padding: '10px', margin: '10px', width: '150px' }}>
      <h4>{product.name}</h4>
      <p>Price: ${product.price}</p>
    </div>
  );
};

export default ProductCard;