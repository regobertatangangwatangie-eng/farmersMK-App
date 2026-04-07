#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SERVICES_DIR="${REPO_ROOT}/services"

mkdir -p "${SERVICES_DIR}"

mapfile -t SERVICE_DIRS < <(
  find "${SERVICES_DIR}" -maxdepth 1 -mindepth 1 -type d -name 'FarmersMK-*' | sort |
  while read -r svc_dir; do
    if [[ -f "${svc_dir}/pom.xml" || -f "${svc_dir}/Dockerfile" || -f "${svc_dir}/dockerfile" || -d "${svc_dir}/src" ]]; then
      basename "${svc_dir}"
    fi
  done
)

if [[ "${#SERVICE_DIRS[@]}" -eq 0 ]]; then
  echo "No valid services found under ${SERVICES_DIR}" >&2
  exit 1
fi

tmp_json="${SERVICES_DIR}/catalog.json.tmp"
printf '[\n' > "${tmp_json}"

for i in "${!SERVICE_DIRS[@]}"; do
  svc="${SERVICE_DIRS[$i]}"
  svc_dir="${SERVICES_DIR}/${svc}"
  mkdir -p "${svc_dir}"
  echo "./services/${svc}" > "${svc_dir}/SERVICE_SOURCE.txt"

  comma=","
  if [[ "$i" -eq $((${#SERVICE_DIRS[@]} - 1)) ]]; then
    comma=""
  fi
  printf '  {"service":"%s","source":"./services/%s"}%s\n' "${svc}" "${svc}" "${comma}" >> "${tmp_json}"
done

printf ']\n' >> "${tmp_json}"
mv "${tmp_json}" "${SERVICES_DIR}/catalog.json"

echo "Synchronized ${#SERVICE_DIRS[@]} services into services/catalog.json"

