# MongoDB Schema for Folder Details

- Database: folder_db
- Collections:
  - folders
  - files

## folders Collection
```json
{
  "_id": ObjectId,
  "name": "folder_name",
  "path": "absolute/path/to/folder",
  "size": 123456,
  "num_files": 42,
  "last_modified": ISODate("2026-05-03T12:34:56Z")
}
```

## files Collection
```json
{
  "_id": ObjectId,
  "folder_id": ObjectId, // Reference to folders._id
  "file_name": "example.txt",
  "file_path": "absolute/path/to/example.txt",
  "file_size": 1234,
  "last_modified": ISODate("2026-05-03T12:34:56Z"),
  "content": "...base64-encoded or raw content..."
}
```
