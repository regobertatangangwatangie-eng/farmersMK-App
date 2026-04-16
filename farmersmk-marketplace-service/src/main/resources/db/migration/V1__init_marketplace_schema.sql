-- Marketplace Service Initial Schema

CREATE TABLE business_account (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(50),
    business_type VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE transaction (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    business_account_id BIGINT NOT NULL,
    amount DECIMAL(18,2) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (business_account_id) REFERENCES business_account(id)
);

CREATE TABLE withdrawal_request (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    business_account_id BIGINT NOT NULL,
    amount DECIMAL(18,2) NOT NULL,
    status VARCHAR(50) NOT NULL,
    document_url VARCHAR(512),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (business_account_id) REFERENCES business_account(id)
);
