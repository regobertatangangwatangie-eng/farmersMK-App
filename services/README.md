# Services Directory

This folder contains the canonical service layout for farmersmk.com.

Each service should have, at minimum:

- `pom.xml`
- `Dockerfile`
- `src/main`
- `src/test`

Only directories with real implementation files are treated as valid services.

Run `scripts/sync-structure.ps1` to refresh `SERVICE_SOURCE.txt` markers and `catalog.json` from the current `services/` tree.
