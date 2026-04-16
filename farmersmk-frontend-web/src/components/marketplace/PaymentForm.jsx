import React, { useState } from 'react';

const PaymentForm = ({ onSubmit }) => {
  const [amount, setAmount] = useState('');
  const [method, setMethod] = useState('');

  const handleSubmit = (e) => {
    e.preventDefault();
    onSubmit({ amount, method });
  };

  return (
    <form onSubmit={handleSubmit}>
      <h3>Make a Payment</h3>
      <input
        type="number"
        placeholder="Amount"
        value={amount}
        onChange={e => setAmount(e.target.value)}
        required
      />
      <select value={method} onChange={e => setMethod(e.target.value)} required>
        <option value="">Select Payment Method</option>
        <option value="MTN Mobile Money">MTN Mobile Money</option>
        <option value="USDT">USDT</option>
        <option value="Master Card">Master Card</option>
        <option value="VISA CARD">VISA CARD</option>
        <option value="Orange Money">Orange Money</option>
      </select>
      <button type="submit">Pay</button>
    </form>
  );
};

export default PaymentForm;
