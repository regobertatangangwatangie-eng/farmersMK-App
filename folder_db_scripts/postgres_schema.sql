-- PostgreSQL schema for storing folder details
CREATE TABLE IF NOT EXISTS folders (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    path TEXT NOT NULL,
    size BIGINT NOT NULL,
    num_files INTEGER NOT NULL,
    last_modified TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS folder_files (
    id SERIAL PRIMARY KEY,
    folder_id INTEGER REFERENCES folders(id) ON DELETE CASCADE,
    file_name TEXT NOT NULL,
    file_path TEXT NOT NULL,
    file_size BIGINT NOT NULL,
    last_modified TIMESTAMP NOT NULL,
    content BYTEA
);