import React, { useEffect, useState } from 'react';

import PaymentForm from './PaymentForm';
import WithdrawalForm from './WithdrawalForm';
import AdminAddProductForm from './AdminAddProductForm';
import { fetchProducts } from '../../api/api';


const MarketplaceDashboard = () => {
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    loadProducts();
  }, []);

  const loadProducts = async () => {
    setLoading(true);
    setError('');
    try {
      const data = await fetchProducts();
      if (Array.isArray(data) && data.length > 0) {
        setProducts(data);
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
    } catch (err) {
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
      setError('Failed to load products. Showing demo products.');
    } finally {
      setLoading(false);
    }
  };

  const handlePayment = (data) => {
    // TODO: Integrate with backend API
    alert(`Payment submitted: ${JSON.stringify(data)}`);
  };

  const handleWithdrawal = (formData) => {
    // TODO: Integrate with backend API
    alert('Withdrawal request submitted.');
  };

  // Check for admin role from localStorage
  let isAdmin = false;
  try {
    const session = JSON.parse(localStorage.getItem('FarmersMK-session'));
    isAdmin = session && session.role && session.role.toUpperCase() === 'ADMIN';
  } catch {}

  return (
    <div className="marketplace-dashboard">
      {isAdmin && (
        <AdminAddProductForm onProductAdded={loadProducts} />
      )}
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
            return (
              <div className="product-card" key={product.id || idx}>
                {product.imageUrl && (
                  <img
                    src={product.imageUrl}
                    alt={product.name}
                    style={{ width: '100%', maxWidth: 220, borderRadius: 8, marginBottom: 8 }}
                    onError={e => { e.target.style.display = 'none'; }}
                  />
                )}
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
