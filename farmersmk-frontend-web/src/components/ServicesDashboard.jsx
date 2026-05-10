import React from 'react';

const services = [
  { label: 'Communication Service', path: '/communication' },
  { label: 'Marketplace Service', path: '/marketplace' },
  { label: 'School Service', path: '/school' },
  { label: 'Grants Service', path: '/grants' },
  { label: 'Wallet Service', path: '/wallet' },
  { label: 'Admin Service', path: '/admin' },
  // Add more services as needed
];

export default function ServicesDashboard() {
  return (
    <section className="panel services-dashboard">
      <h2>Services</h2>
      <ul style={{ listStyle: 'none', padding: 0 }}>
        {services.map((service) => (
          <li key={service.label} style={{ margin: '1rem 0' }}>
            <a href={service.path} className="btn btn-primary" style={{ width: '100%', display: 'block', textAlign: 'left' }}>
              {service.label}
            </a>
          </li>
        ))}
      </ul>
    </section>
  );
}
