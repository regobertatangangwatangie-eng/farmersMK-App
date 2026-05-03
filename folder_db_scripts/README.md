# Folder Database Schema and Ingestion Scripts

This directory will contain scripts to scan the workspace folders and store their metadata and contents into PostgreSQL and MongoDB databases.

## Requirements
- Python 3.x
- `psycopg2` (for PostgreSQL)
- `pymongo` (for MongoDB)

Install dependencies:
```
pip install psycopg2-binary pymongo
```

## Usage
1. Update database connection settings in the scripts.
2. Run `scan_and_store.py` to scan folders and store their details.

---

- `scan_and_store.py`: Main script to scan folders and store data.
- `postgres_schema.sql`: SQL schema for PostgreSQL.
- `mongodb_schema.md`: MongoDB collection structure.
