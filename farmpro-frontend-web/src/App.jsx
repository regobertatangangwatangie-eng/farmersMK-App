import React from 'react';
import Home from './pages/home.jsx';
import Products from './pages/products.jsx';
import Admin from './pages/Admin.jsx';

const groups = [
  {
    title: 'Main Entry',
    links: [
      { label: 'Unified Hub', url: 'http://localhost' },
      { label: 'Frontend UI', url: 'http://localhost/ui' },
      { label: 'API Gateway', url: 'http://localhost/gateway' },
      { label: 'Frontend (Vite Dev)', url: 'http://localhost:5173' }
    ]
  },
  {
    title: 'Core Services',
    links: [
      { label: 'Admin', url: 'http://localhost/admin/users' },
      { label: 'User', url: 'http://localhost/users' },
      { label: 'Marketplace', url: 'http://localhost/products' },
      { label: 'Notification', url: 'http://localhost/api/notifications' },
      { label: 'Post', url: 'http://localhost/posts' },
      { label: 'Wallet', url: 'http://localhost/wallets' },
      { label: 'Realtime Socket', url: 'http://localhost/ws' }
    ]
  },
  {
    title: 'Payments',
    links: [
      { label: 'Mastercard', url: 'http://localhost/api/mastercard/pay' },
      { label: 'VISA', url: 'http://localhost/api/visacard/pay' },
      { label: 'MTN Mobile Money', url: 'http://localhost/mtn' },
      { label: 'Orange Money', url: 'http://localhost/orangemoney/send' },
      { label: 'Crypto Wallet', url: 'http://localhost/api/crypto/transfer' }
    ]
  },
  {
    title: 'Social',
    links: [
      { label: 'Facebook', url: 'http://localhost/facebook/post' },
      { label: 'Instagram', url: 'http://localhost/api/instagram/ads' },
      { label: 'Twitter/X', url: 'http://localhost/twitter/posts' }
    ]
  }
];

function App() {
  return (
    <div style={{
      minHeight: '100vh',
      background: 'linear-gradient(180deg, #0f4ea8 0%, #1f6fd1 55%, #3e8ef0 100%)',
      color: '#eaf3ff',
      fontFamily: 'Segoe UI, Tahoma, sans-serif',
      padding: '18px'
    }}>
      <h1 style={{ margin: '0 0 8px 0' }}>FARMERPRO Frontend Service Dashboard</h1>
      <p style={{ margin: '0 0 16px 0', color: '#d0e4ff' }}>
        One localhost entry point for the full local platform.
      </p>

      <div style={{
        display: 'grid',
        gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))',
        gap: '12px',
        marginBottom: '18px'
      }}>
        {groups.map((group) => (
          <section key={group.title} style={{
            background: 'rgba(255, 255, 255, 0.14)',
            border: '1px solid rgba(255, 255, 255, 0.32)',
            borderRadius: '12px',
            padding: '12px',
            boxShadow: '0 4px 14px rgba(6, 29, 77, 0.24)',
            backdropFilter: 'blur(3px)'
          }}>
            <h2 style={{ margin: '0 0 10px 0', fontSize: '17px' }}>{group.title}</h2>
            <div style={{ display: 'flex', flexWrap: 'wrap', gap: '8px' }}>
              {group.links.map((link) => (
                <a
                  key={link.url}
                  href={link.url}
                  target="_blank"
                  rel="noreferrer"
                  style={{
                    textDecoration: 'none',
                    fontWeight: 700,
                    fontSize: '12px',
                    color: '#083370',
                    background: 'linear-gradient(90deg, #b7d8ff, #8bc0ff)',
                    borderRadius: '999px',
                    padding: '7px 10px'
                  }}
                >
                  {link.label}
                </a>
              ))}
            </div>
          </section>
        ))}
      </div>

      <section style={{
        background: 'rgba(255, 255, 255, 0.14)',
        border: '1px solid rgba(255, 255, 255, 0.32)',
        borderRadius: '12px',
        padding: '12px'
      }}>
        <h2 style={{ marginTop: 0, marginBottom: '8px', fontSize: '17px' }}>Existing Frontend Pages</h2>
        <Home />
        <Products />
        <Admin />
      </section>
    </div>
  );
}

export default App;