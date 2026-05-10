import React from 'react';

export default function SigninPage({ onSignin, signinForm, signinState, handleSigninChange, handleSigninSubmit, currentSession, handleSignOut }) {
  return (
    <section className="auth-grid page">
      <article id="signin" className="auth-card">
        <h2>Sign In</h2>
        <p className="auth-copy">Access your marketplace, wallet, and analytics dashboard.</p>
        <form onSubmit={handleSigninSubmit}>
          <label htmlFor="signin-email">Email</label>
          <input
            id="signin-email"
            type="email"
            placeholder="you@FarmersMK.com"
            value={signinForm.email}
            onChange={e => handleSigninChange('email', e.target.value)}
          />
          <label htmlFor="signin-password">Password</label>
          <input
            id="signin-password"
            type="password"
            placeholder="Enter your password"
            value={signinForm.password}
            onChange={e => handleSigninChange('password', e.target.value)}
          />
          <div className="remember-row">
            <label className="remember">
              <input
                type="checkbox"
                checked={signinForm.remember}
                onChange={e => handleSigninChange('remember', e.target.checked)}
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
  );
}
