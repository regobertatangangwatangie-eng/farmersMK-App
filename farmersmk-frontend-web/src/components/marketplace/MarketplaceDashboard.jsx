import React, { useEffect, useState } from 'react';
import PaymentForm from './PaymentForm';
import WithdrawalForm from './WithdrawalForm';
import { fetchProducts } from '../../api/api';


const MarketplaceDashboard = () => {
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    const loadProducts = async () => {
      setLoading(true);
      setError('');
      try {
        const data = await fetchProducts();
        setProducts(Array.isArray(data) ? data : []);
      } catch (err) {
        setError('Failed to load products.');
      } finally {
        setLoading(false);
      }
    };
    loadProducts();
  }, []);

  const handlePayment = (data) => {
    // TODO: Integrate with backend API
    alert(`Payment submitted: ${JSON.stringify(data)}`);
  };

  const handleWithdrawal = (formData) => {
    // TODO: Integrate with backend API
    alert('Withdrawal request submitted.');
  };

  return (
    <div className="marketplace-dashboard">
      <h2>Marketplace Products</h2>
      {loading ? (
        <p>Loading products...</p>
      ) : error ? (
        <p className="error-message">{error}</p>
      ) : products.length === 0 ? (
        <p>No products available.</p>

      ) : (
        <div className="product-list">
          {products.map((product, idx) => {
            // Alternate images and prices for demo
            let imageUrl = "https://raw.githubusercontent.com/regobertatangangwatangie-eng/farmersMK-App/master/docs/tomato-basket-demo.jpg";
            let priceLabel = "1 kg = $10";
            let alt = "Tomato Basket";
            if (idx === 1) {
              imageUrl = "https://raw.githubusercontent.com/regobertatangangwatangie-eng/farmersMK-App/master/docs/plantain-demo.jpg";
              priceLabel = "1 kg = $5";
              alt = "Plantains";
            }
            return (
              <div className="product-card" key={product.id || idx}>
                <img
                  src={imageUrl}
                  alt={alt}
                  style={{ width: '100%', maxWidth: 220, borderRadius: 8, marginBottom: 8 }}
                  onError={e => { e.target.style.display = 'none'; }}
                />
                <div style={{ fontWeight: 'bold', color: '#2e7d32', marginBottom: 8 }}>{priceLabel}</div>
                <h3>{product.name}</h3>
                <p>{product.description}</p>
                <strong>Price: {product.price} XAF</strong>
              </div>
            );
          })}
        </div>
      )}

      <h2>Marketplace Payments & Withdrawals</h2>
      <div className="dashboard-forms">
        <PaymentForm onSubmit={handlePayment} />
        <WithdrawalForm onSubmit={handleWithdrawal} />
      </div>
    </div>
  );
};

export default MarketplaceDashboard;
