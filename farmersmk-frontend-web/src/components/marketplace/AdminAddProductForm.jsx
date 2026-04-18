import React, { useState } from 'react';
import axios from 'axios';

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || import.meta.env.VITE_API_GATEWAY_URL || 'http://localhost:8080';

const AdminAddProductForm = ({ onProductAdded }) => {
  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [price, setPrice] = useState('');
  const [imageUrl, setImageUrl] = useState('');
  const [message, setMessage] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setMessage('');
    try {
      const response = await axios.post(`${API_BASE_URL.replace(/\/$/, '')}/products`, {
        name,
        description,
        price: Number(price),
        imageUrl
      });
      setMessage('Product added successfully!');
      setName('');
      setDescription('');
      setPrice('');
      setImageUrl('');
      if (onProductAdded) onProductAdded(response.data);
    } catch (err) {
      setMessage('Failed to add product.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} style={{ margin: '2em 0', padding: '1em', border: '1px solid #ccc', borderRadius: 8 }}>
      <h3>Add New Product (Admin)</h3>
      <div>
        <label>Name:</label><br />
        <input value={name} onChange={e => setName(e.target.value)} required />
      </div>
      <div>
        <label>Description:</label><br />
        <textarea value={description} onChange={e => setDescription(e.target.value)} required />
      </div>
      <div>
        <label>Price (XAF):</label><br />
        <input type="number" value={price} onChange={e => setPrice(e.target.value)} required />
      </div>
      <div>
        <label>Image URL:</label><br />
        <input value={imageUrl} onChange={e => setImageUrl(e.target.value)} required />
      </div>
      <button type="submit" disabled={loading} style={{ marginTop: 10 }}>
        {loading ? 'Adding...' : 'Add Product'}
      </button>
      {message && <div style={{ marginTop: 10 }}>{message}</div>}
    </form>
  );
};

export default AdminAddProductForm;
