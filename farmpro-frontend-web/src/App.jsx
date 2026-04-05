import React, { useMemo, useState } from 'react';
import { fetchUsersAdmin, loginUser, registerUser } from './api/api';

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

const quickLinks = [
  { label: 'Open Marketplace API', url: 'http://localhost/products' },
  { label: 'Open Gateway', url: 'http://localhost/gateway' },
  { label: 'Open Realtime Endpoint', url: 'http://localhost/ws' },
  { label: 'Open Service Hub', url: 'http://localhost/services.html' }
];

function App() {
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
      const raw = localStorage.getItem('farmpro-session');
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

      localStorage.setItem('farmpro-token', response.token);
      localStorage.setItem('farmpro-session', JSON.stringify({
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

      localStorage.setItem('farmpro-token', response.token);
      localStorage.setItem('farmpro-session', JSON.stringify(session));
      setSigninState({
        loading: false,
        message: `Welcome back, ${response.name || response.email}. Sign in successful.`,
        type: 'success'
      });
      setSigninForm({ email: '', password: '', remember: false });
    } catch (error) {
      setSigninState({ loading: false, message: error.message, type: 'error' });
    }
  };

  const handleSignOut = () => {
    localStorage.removeItem('farmpro-token');
    localStorage.removeItem('farmpro-session');
    setAdminUsers([]);
    setAdminState({ loading: false, message: 'Signed out successfully.', type: 'success' });
    setSigninState((prev) => ({ ...prev, message: '' }));
    setSignupState((prev) => ({ ...prev, message: '' }));
  };

  const handleLoadUsers = async () => {
    const token = localStorage.getItem('farmpro-token');
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
        <div className="badge">FARMERPRO-APP</div>
        <h1>Grow farm businesses with one digital operating platform.</h1>
        <p>
          FARMERPRO connects farmers, buyers, logistics, payments, and social outreach in one
          integrated microservices ecosystem.
        </p>
        <div className="hero-actions">
          <a className="btn btn-primary" href="#signup">Create account</a>
          <a className="btn btn-secondary" href="#signin">Sign in</a>
          <a className="btn btn-link" href="#features">Explore features</a>
        </div>
      </header>

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

      <section className="auth-grid">
        <article id="signup" className="auth-card">
          <h2>Create an Account</h2>
          <p className="auth-copy">Start as a Farmer, Buyer, or Agro Partner.</p>
          <form onSubmit={handleSignupSubmit}>
            <label htmlFor="signup-name">Full name</label>
            <input
              id="signup-name"
              type="text"
              placeholder="Jane Nkongho"
              value={signupForm.name}
              onChange={(event) => handleSignupChange('name', event.target.value)}
            />

            <label htmlFor="signup-email">Email</label>
            <input
              id="signup-email"
              type="email"
              placeholder="jane@farmpro.com"
              value={signupForm.email}
              onChange={(event) => handleSignupChange('email', event.target.value)}
            />

            <label htmlFor="signup-role">Role</label>
            <select
              id="signup-role"
              value={signupForm.role}
              onChange={(event) => handleSignupChange('role', event.target.value)}
            >
              <option>Farmer</option>
              <option>Buyer</option>
              <option>Agro Partner</option>
              <option>Investor</option>
            </select>

            <label htmlFor="signup-password">Password</label>
            <input
              id="signup-password"
              type="password"
              placeholder="Create a strong password"
              value={signupForm.password}
              onChange={(event) => handleSignupChange('password', event.target.value)}
            />

            {signupState.message ? (
              <p className={`form-message ${signupState.type}`}>{signupState.message}</p>
            ) : null}

            <button type="submit" disabled={signupState.loading}>
              {signupState.loading ? 'Creating account...' : 'Sign up'}
            </button>
          </form>
        </article>

        <article id="signin" className="auth-card">
          <h2>Sign In</h2>
          <p className="auth-copy">Access your marketplace, wallet, and analytics dashboard.</p>
          <form onSubmit={handleSigninSubmit}>
            <label htmlFor="signin-email">Email</label>
            <input
              id="signin-email"
              type="email"
              placeholder="you@farmpro.com"
              value={signinForm.email}
              onChange={(event) => handleSigninChange('email', event.target.value)}
            />

            <label htmlFor="signin-password">Password</label>
            <input
              id="signin-password"
              type="password"
              placeholder="Enter your password"
              value={signinForm.password}
              onChange={(event) => handleSigninChange('password', event.target.value)}
            />

            <div className="remember-row">
              <label className="remember">
                <input
                  type="checkbox"
                  checked={signinForm.remember}
                  onChange={(event) => handleSigninChange('remember', event.target.checked)}
                />
                Keep me signed in
              </label>
              <a href="#signin">Forgot password?</a>
            </div>

            {signinState.message ? (
              <p className={`form-message ${signinState.type}`}>{signinState.message}</p>
            ) : null}

            <button type="submit" disabled={signinState.loading}>
              {signinState.loading ? 'Signing in...' : 'Sign in'}
            </button>
          </form>

          {currentSession ? (
            <p className="session-note">
              Active session: {currentSession.email} ({currentSession.role})
            </p>
          ) : null}

          {currentSession ? (
            <button className="signout-btn" type="button" onClick={handleSignOut}>Sign out</button>
          ) : null}
        </article>
      </section>

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
            FARMERPRO-APP is a modular agri-fintech platform built with Spring Boot microservices,
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
    </div>
  );
}

export default App;