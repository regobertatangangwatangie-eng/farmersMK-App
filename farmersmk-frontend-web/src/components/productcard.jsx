import React from 'react';

const ProductCard = ({ product }) => {
  return (
    <article className="product-card">
      <h4 className="product-card__name">{product.name}</h4>
      <p className="product-card__price">${product.price}</p>
    </article>
  );
};

export default ProductCard;