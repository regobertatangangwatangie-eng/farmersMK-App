# Automation script to set up PostgreSQL and MongoDB for folder database
# Usage: Run this script with Python 3
# - Creates PostgreSQL database and tables
# - Creates MongoDB database and collections (MongoDB is schemaless, so just ensures connection)

import subprocess
import psycopg2
from pymongo import MongoClient

# --- CONFIGURATION ---
POSTGRES = {
    'dbname': 'postgres',  # Connect to default db for admin tasks
    'user': 'postgres',
    'password': 'password',
    'host': 'localhost',
    'port': 5432
}
FOLDER_DB = 'folder_db'
MONGO_URI = 'mongodb://localhost:27017/'
MONGO_DB = 'folder_db'

# --- PostgreSQL Setup ---
def setup_postgres():
    print('Setting up PostgreSQL...')
    conn = psycopg2.connect(**POSTGRES)
    conn.autocommit = True
    cur = conn.cursor()
    # Create database if not exists
    cur.execute(f"SELECT 1 FROM pg_database WHERE datname = '{FOLDER_DB}'")
    exists = cur.fetchone()
    if not exists:
        cur.execute(f'CREATE DATABASE {FOLDER_DB}')
        print(f"Database '{FOLDER_DB}' created.")
    else:
        print(f"Database '{FOLDER_DB}' already exists.")
    cur.close()
    conn.close()
    # Connect to folder_db and create tables
    db_conn = psycopg2.connect(dbname=FOLDER_DB, user=POSTGRES['user'], password=POSTGRES['password'], host=POSTGRES['host'], port=POSTGRES['port'])
    db_cur = db_conn.cursor()
    with open('folder_db_scripts/postgres_schema.sql', 'r') as f:
        db_cur.execute(f.read())
    db_conn.commit()
    db_cur.close()
    db_conn.close()
    print('PostgreSQL tables created.')

# --- MongoDB Setup ---
def setup_mongo():
    print('Setting up MongoDB...')
    client = MongoClient(MONGO_URI)
    db = client[MONGO_DB]
    # Insert dummy doc to ensure collections exist
    db.folders.insert_one({'setup': True})
    db.files.insert_one({'setup': True})
    db.folders.delete_many({'setup': True})
    db.files.delete_many({'setup': True})
    client.close()
    print('MongoDB database and collections ready.')

if __name__ == '__main__':
    setup_postgres()
    setup_mongo()
    print('Database setup complete.')
