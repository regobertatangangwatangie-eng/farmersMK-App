import os
import sys
import base64
import psycopg2
from pymongo import MongoClient
from datetime import datetime

# --- CONFIGURATION ---
# Update these with your actual database connection details
POSTGRES = {
    'dbname': 'folder_db',
    'user': 'postgres',
    'password': 'password',
    'host': 'localhost',
    'port': 5432
}
MONGO_URI = 'mongodb://localhost:27017/'
MONGO_DB = 'folder_db'

# --- FOLDER LIST ---
FOLDERS = [
    'ci-cd', 'DevOps', 'docker', 'docker-compose.build.yml', 'docker-compose.local.yml',
    'docker-compose.prod.yml', 'docs', 'farmersmk-access-key', 'farmersmk-access-key.pub',
    'farmersmk-android-app', 'farmersmk-common-lib', 'farmersmk-ec2.pub', 'farmersmk-frontend-mobile',
    'farmersmk-frontend-web', 'farmersmk-marketplace-service', 'farmersmk-payment-service',
    'farmersmk-terraform', 'fix-k3s.sh', 'frontend', 'infrastructure', 'kubernetes', 'maven-settings.xml',
    'package-lock.json', 'README.md', 'scan-deps.js', 'scripts', 'services'
]

# --- HELPERS ---
def get_folder_details(folder_path):
    total_size = 0
    num_files = 0
    last_modified = None
    for root, dirs, files in os.walk(folder_path):
        for f in files:
            fp = os.path.join(root, f)
            try:
                stat = os.stat(fp)
                total_size += stat.st_size
                num_files += 1
                lm = datetime.fromtimestamp(stat.st_mtime)
                if last_modified is None or lm > last_modified:
                    last_modified = lm
            except Exception:
                continue
    if last_modified is None:
        last_modified = datetime.now()
    return total_size, num_files, last_modified

def get_files(folder_path):
    file_list = []
    for root, dirs, files in os.walk(folder_path):
        for f in files:
            fp = os.path.join(root, f)
            try:
                stat = os.stat(fp)
                with open(fp, 'rb') as file:
                    content = file.read()
                file_list.append({
                    'file_name': f,
                    'file_path': fp,
                    'file_size': stat.st_size,
                    'last_modified': datetime.fromtimestamp(stat.st_mtime),
                    'content': content
                })
            except Exception:
                continue
    return file_list

# --- POSTGRESQL INGESTION ---
def store_in_postgres(folder_name, folder_path, size, num_files, last_modified, files):
    conn = psycopg2.connect(**POSTGRES)
    cur = conn.cursor()
    cur.execute("""
        INSERT INTO folders (name, path, size, num_files, last_modified)
        VALUES (%s, %s, %s, %s, %s) RETURNING id
    """, (folder_name, folder_path, size, num_files, last_modified))
    folder_id = cur.fetchone()[0]
    for f in files:
        cur.execute("""
            INSERT INTO folder_files (folder_id, file_name, file_path, file_size, last_modified, content)
            VALUES (%s, %s, %s, %s, %s, %s)
        """, (folder_id, f['file_name'], f['file_path'], f['file_size'], f['last_modified'], f['content']))
    conn.commit()
    cur.close()
    conn.close()

# --- MONGODB INGESTION ---
def store_in_mongo(folder_name, folder_path, size, num_files, last_modified, files):
    client = MongoClient(MONGO_URI)
    db = client[MONGO_DB]
    folder_doc = {
        'name': folder_name,
        'path': folder_path,
        'size': size,
        'num_files': num_files,
        'last_modified': last_modified
    }
    folder_id = db.folders.insert_one(folder_doc).inserted_id
    for f in files:
        file_doc = {
            'folder_id': folder_id,
            'file_name': f['file_name'],
            'file_path': f['file_path'],
            'file_size': f['file_size'],
            'last_modified': f['last_modified'],
            'content': f['content']
        }
        db.files.insert_one(file_doc)
    client.close()

# --- MAIN ---
def main():
    base_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
    for folder in FOLDERS:
        folder_path = os.path.join(base_dir, folder)
        if not os.path.exists(folder_path):
            continue
        size, num_files, last_modified = get_folder_details(folder_path)
        files = get_files(folder_path)
        print(f"Storing {folder} ({num_files} files, {size} bytes)...")
        store_in_postgres(folder, folder_path, size, num_files, last_modified, files)
        store_in_mongo(folder, folder_path, size, num_files, last_modified, files)
    print("Done.")

if __name__ == '__main__':
    main()
