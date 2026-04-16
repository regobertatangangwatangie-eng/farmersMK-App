import React, { useState } from 'react';

const WithdrawalForm = ({ onSubmit }) => {
  const [amount, setAmount] = useState('');
  const [document, setDocument] = useState(null);

  const handleSubmit = (e) => {
    e.preventDefault();
    const formData = new FormData();
    formData.append('amount', amount);
    if (document) formData.append('document', document);
    onSubmit(formData);
  };

  return (
    <form onSubmit={handleSubmit} encType="multipart/form-data">
      <h3>Request Withdrawal</h3>
      <input
        type="number"
        placeholder="Amount"
        value={amount}
        onChange={e => setAmount(e.target.value)}
        required
      />
      <input
        type="file"
        accept="image/*,application/pdf"
        onChange={e => setDocument(e.target.files[0])}
      />
      <button type="submit">Withdraw</button>
    </form>
  );
};

export default WithdrawalForm;
