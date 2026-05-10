import React, { useMemo, useState } from 'react';
import { Routes, Route, useNavigate } from 'react-router-dom';
import { fetchUsersAdmin, loginUser, registerUser } from './api/api';
import MarketplaceDashboard from './components/marketplace/MarketplaceDashboard';
import ServicesDashboard from './components/ServicesDashboard';
import SigninPage from './pages/SigninPage';
import SignupPage from './pages/SignupPage';

const featureCards = [
  {
    title: 'Marketplace Commerce',
    text: 'Farmers list products, buyers order quickly, and inventory updates in near real-time.'
  },
  {
    title: 'Multi-Payment Checkout',
    text: 'Accept VISA, Mastercard, MTN Mobile Money, Orange Money, and crypto wallet transactions.'
  },
  {
    title: 'Farmer Social Reach',
    text: 'Publish farm stories and campaigns to Facebook, Instagram, and Twitter from one platform.'
  },
  {
    title: 'Realtime Collaboration',
    text: 'Socket channels power instant updates for order status, notifications, and team messaging.'
  }
];

const serviceHighlights = [
  'API Gateway with centralized routing and security',
  'Admin, User, Wallet, Post, and Notification microservices',
  'PostgreSQL + Redis for resilient data and caching',
  'Dockerized deployment with CI/CD on GitHub Actions'
];

const API_BASE_URL = (import.meta.env.VITE_API_BASE_URL || import.meta.env.VITE_API_GATEWAY_URL || 'http://localhost:8080').replace(/\/$/, '');
const REALTIME_URL = import.meta.env.VITE_REALTIME_URL || `${API_BASE_URL.replace(/^http/, 'ws')}/ws`;
const SERVICE_HUB_URL = import.meta.env.VITE_SERVICE_HUB_URL || '/services.html';

const quickLinks = [
  { label: 'Open Marketplace API', url: `${API_BASE_URL}/products` },
  { label: 'Open Gateway', url: API_BASE_URL },
  { label: 'Open Realtime Endpoint', url: REALTIME_URL },
  { label: 'Open Service Hub', url: SERVICE_HUB_URL }
];

function App() {
  const navigate = useNavigate();
  const [view, setView] = useState('home'); // 'home', 'marketplace', etc.
  const [signupForm, setSignupForm] = useState({
    name: '',
    email: '',
    role: 'Farmer',
    password: ''
  });
  const [signinForm, setSigninForm] = useState({
    email: '',
    password: '',
    remember: false
  });
  const [signupState, setSignupState] = useState({ loading: false, message: '', type: '' });
  const [signinState, setSigninState] = useState({ loading: false, message: '', type: '' });
  const [adminState, setAdminState] = useState({ loading: false, message: '', type: '' });
  const [adminUsers, setAdminUsers] = useState([]);

  const currentSession = useMemo(() => {
    try {
      const raw = localStorage.getItem('FarmersMK-session');
      return raw ? JSON.parse(raw) : null;
    } catch (error) {
      return null;
    }
  }, [signinState.message, signupState.message]);

  const currentRole = (currentSession?.role || '').toUpperCase();
  const isAdmin = currentRole === 'ADMIN';

  const handleSignupChange = (field, value) => {
    setSignupForm((prev) => ({ ...prev, [field]: value }));
  };

  const handleSigninChange = (field, value) => {
    setSigninForm((prev) => ({ ...prev, [field]: value }));
  };

  const handleSignupSubmit = async (event) => {
    event.preventDefault();
    setSignupState({ loading: true, message: '', type: '' });

    const name = signupForm.name.trim();
    const email = signupForm.email.trim().toLowerCase();
    const password = signupForm.password;

    if (!name || !email || !password) {
      setSignupState({
        loading: false,
        message: 'Please fill all sign up fields.',
        type: 'error'
      });
      return;
    }

    if (password.length < 6) {
      setSignupState({
        loading: false,
        message: 'Password should be at least 6 characters.',
        type: 'error'
      });
      return;
    }

    try {
      const response = await registerUser({
        name,
        email,
        role: signupForm.role,
        password
      });

      localStorage.setItem('FarmersMK-token', response.token);
      localStorage.setItem('FarmersMK-session', JSON.stringify({
        userId: response.userId,
        email: response.email,
        role: response.role,
        name: response.name,
        signedInAt: new Date().toISOString(),
        remember: true
      }));

      setSignupState({
        loading: false,
        message: 'Account created and signed in successfully.',
        type: 'success'
      });

      setSignupForm({
        name: '',
        email: '',
        role: 'Farmer',
        password: ''
      });

      navigate('/services');
    } catch (error) {
      setSignupState({ loading: false, message: error.message, type: 'error' });
    }
  };

  const handleSigninSubmit = async (event) => {
    event.preventDefault();
    setSigninState({ loading: true, message: '', type: '' });

    const email = signinForm.email.trim().toLowerCase();
    const password = signinForm.password;

    if (!email || !password) {
      setSigninState({
        loading: false,
        message: 'Please enter email and password.',
        type: 'error'
      });
      return;
    }

    try {
      const response = await loginUser({ email, password });

      const session = {
        userId: response.userId,
        email: response.email,
        role: response.role,
        name: response.name,
        signedInAt: new Date().toISOString(),
        remember: signinForm.remember
      };

      localStorage.setItem('FarmersMK-token', response.token);
      localStorage.setItem('FarmersMK-session', JSON.stringify(session));
      setSigninState({
        loading: false,
        message: `Welcome back, ${response.name || response.email}. Sign in successful.`,
        type: 'success'
      });
      setSigninForm({ email: '', password: '', remember: false });
      navigate('/services');
    } catch (error) {
      setSigninState({ loading: false, message: error.message, type: 'error' });
    }
  };

  const handleSignOut = () => {
    localStorage.removeItem('FarmersMK-token');
    localStorage.removeItem('FarmersMK-session');
    setAdminUsers([]);
    setAdminState({ loading: false, message: 'Signed out successfully.', type: 'success' });
    setSigninState((prev) => ({ ...prev, message: '' }));
    setSignupState((prev) => ({ ...prev, message: '' }));
  };

  const handleLoadUsers = async () => {
    const token = localStorage.getItem('FarmersMK-token');
    if (!token) {
      setAdminState({ loading: false, message: 'No token found. Please sign in again.', type: 'error' });
      return;
    }

    setAdminState({ loading: true, message: '', type: '' });
    try {
      const users = await fetchUsersAdmin(token);
      setAdminUsers(users);
      setAdminState({
        loading: false,
        message: `Loaded ${users.length} users from protected endpoint.`,
        type: 'success'
      });
    } catch (error) {
      setAdminUsers([]);
      setAdminState({ loading: false, message: error.message, type: 'error' });
    }
  };


    return (
    <div className="landing">
      <header className="hero-shell">
        <div className="badge">farmersmk.com</div>
        <h1>Grow farm businesses with one digital operating platform.</h1>
        <p>
          farmersmk connects farmers, buyers, logistics, payments, and social outreach in one
          integrated microservices ecosystem.
        </p>
        <nav className="main-nav" style={{ margin: '1.5rem 0' }}>
          <button className="btn btn-primary" onClick={() => navigate('/signup')}>Create account</button>
          <button className="btn btn-secondary" onClick={() => navigate('/signin')}>Sign in</button>
          <button className="btn btn-link" onClick={() => setView('marketplace')}>Marketplace</button>
          <button className="btn btn-link" onClick={() => setView('home')}>Home</button>
        </nav>
      </header>

      <Routes>
        <Route
          path="/"
          element={
            view === 'home' && (
              <section id="features" className="panel">
                <div className="panel-head">
                  <h2>What You Can Do</h2>
                  <p>
                    Launch an end-to-end agri-commerce operation from onboarding to payment settlement.
                  </p>
                </div>
                <div className="feature-grid">
                  {featureCards.map((card) => (
                    <article className="feature-card" key={card.title}>
                      <h3>{card.title}</h3>
                      <p>{card.text}</p>
                    </article>
                  ))}
                </div>
              </section>
            )
          }
        />
        <Route
          path="/signin"
          element={
            <SigninPage
              signinForm={signinForm}
              signinState={signinState}
              handleSigninChange={handleSigninChange}
              handleSigninSubmit={handleSigninSubmit}
              currentSession={currentSession}
              handleSignOut={handleSignOut}
            />
          }
        />
        <Route
          path="/signup"
          element={
            <SignupPage
              signupForm={signupForm}
              signupState={signupState}
              handleSignupChange={handleSignupChange}
              handleSignupSubmit={handleSignupSubmit}
            />
          }
        />

        <Route
          path="/services"
          element={<ServicesDashboard />}
        />
      </Routes>


      {/* Modals removed, now handled by routes */}

      {view === 'marketplace' && (
        <section className="panel">
          <MarketplaceDashboard />
        </section>
      )}

      {/* Always show admin panel and project info for demo/testing */}
      <section className="panel admin-panel">
        <div className="panel-head">
          <h2>Admin Console</h2>
          <p>
            Protected actions are visible only for ADMIN role.
          </p>
        </div>

        {currentSession ? (
          <p className="role-badge">
            Current role: {currentSession.role}
          </p>
        ) : (
          <p className="role-badge muted">Sign in to view role-based features.</p>
        )}

        {isAdmin ? (
          <div className="admin-tools">
            <button type="button" onClick={handleLoadUsers} disabled={adminState.loading}>
              {adminState.loading ? 'Loading users...' : 'Load all users'}
            </button>

            {adminState.message ? (
              <p className={`form-message ${adminState.type}`}>{adminState.message}</p>
            ) : null}

            {adminUsers.length > 0 ? (
              <div className="admin-users">
                {adminUsers.slice(0, 8).map((user) => (
                  <div key={user.id || user.email} className="admin-user-row">
                    <strong>{user.name}</strong>
                    <span>{user.email}</span>
                    <em>{user.role}</em>
                  </div>
                ))}
              </div>
            ) : null}
          </div>
        ) : (
          <p className="locked-note">
            Admin tools are locked. Sign in with an ADMIN account to access protected actions.
          </p>
        )}
      </section>

      <section className="panel split-panel">
        <article>
          <h2>Project Introduction</h2>
          <p>
            farmersmk.com is a modular agri-fintech platform built with Spring Boot microservices,
            a React frontend, and cloud-ready DevOps automation. It helps farming communities manage
            product sales, digital payments, and online visibility from a single stack.
          </p>
          <ul>
            {serviceHighlights.map((highlight) => (
              <li key={highlight}>{highlight}</li>
            ))}
          </ul>
        </article>
        <article>
          <h2>Quick Access</h2>
          <p>Use these links to jump directly into running local endpoints.</p>
          <div className="quick-links">
            {quickLinks.map((link) => (
              <a key={link.url} href={link.url} target="_blank" rel="noreferrer">
                {link.label}
              </a>
            ))}
          </div>
        </article>
      </section>

      <footer className="site-footer">
        <div className="footer-inner">
          <span className="footer-brand">farmersmk.com</span>
          <span className="footer-divider">|</span>
          <span className="footer-cto">
            CTO: <strong>Regobert Atanga Ngwa Tangie</strong>
          </span>
          <span className="footer-divider">|</span>
          <span className="footer-contact">
            <a href="tel:+237675142175">+237 675 142 175</a>
            {' / '}
            <a href="tel:+237651868099">+237 651 868 099</a>
            {' / '}
            <a href="mailto:regobert2004@gmail.com">regobert2004@gmail.com</a>
          </span>
        </div>
      </footer>
    </div>
    );
  }

export default App;