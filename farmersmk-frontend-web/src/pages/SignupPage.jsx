import React from 'react';

export default function SignupPage({ onSignup, signupForm, signupState, handleSignupChange, handleSignupSubmit }) {
  return (
    <section className="auth-grid page">
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
            onChange={e => handleSignupChange('name', e.target.value)}
          />
          <label htmlFor="signup-email">Email</label>
          <input
            id="signup-email"
            type="email"
            placeholder="jane@FarmersMK.com"
            value={signupForm.email}
            onChange={e => handleSignupChange('email', e.target.value)}
          />
          <label htmlFor="signup-role">Role</label>
          <select
            id="signup-role"
            value={signupForm.role}
            onChange={e => handleSignupChange('role', e.target.value)}
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
            onChange={e => handleSignupChange('password', e.target.value)}
          />
          {signupState.message ? (
            <p className={`form-message ${signupState.type}`}>{signupState.message}</p>
          ) : null}
          <button type="submit" disabled={signupState.loading}>
            {signupState.loading ? 'Creating account...' : 'Sign up'}
          </button>
        </form>
      </article>
    </section>
  );
}
