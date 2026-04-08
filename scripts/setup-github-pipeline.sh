#!/usr/bin/env bash
# ── farmersMK: Register GitHub Webhook + GitHub Actions Secrets ───────────────
# Run this from your local machine after terraform apply.
#
# Prerequisites:
#   - GitHub CLI (gh) installed and authenticated (gh auth login)
#   - OR set GITHUB_TOKEN env var with a PAT that has:
#       repo, admin:repo_hook, secrets scopes
#
# Usage:
#   chmod +x scripts/setup-github-pipeline.sh
#   ./scripts/setup-github-pipeline.sh
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

# ── Configuration — edit these or export as env vars before running ───────────
GITHUB_OWNER="${GITHUB_OWNER:-YOUR_GITHUB_USERNAME}"
GITHUB_REPO="${GITHUB_REPO:-farmersMK-App}"
GITHUB_TOKEN="${GITHUB_TOKEN:-}"            # PAT with repo + admin:repo_hook + secrets

# IPs from terraform output
JENKINS_IP="${JENKINS_IP:-44.199.227.239}"
K8S_IP="${K8S_IP:-100.48.216.40}"
ANSIBLE_IP="${ANSIBLE_IP:-98.92.240.160}"
DOCKER_IP="${DOCKER_IP:-3.222.188.212}"

# Docker Hub
DOCKERHUB_USERNAME="${DOCKERHUB_USERNAME:-}"
DOCKERHUB_TOKEN="${DOCKERHUB_TOKEN:-}"

# SSH private key path (your id_ed25519)
SSH_KEY_PATH="${SSH_KEY_PATH:-$HOME/.ssh/id_ed25519}"
# ─────────────────────────────────────────────────────────────────────────────

if [[ -z "$GITHUB_TOKEN" ]]; then
  # Try gh CLI
  if command -v gh &>/dev/null; then
    GITHUB_TOKEN=$(gh auth token)
  else
    echo "ERROR: set GITHUB_TOKEN or install GitHub CLI (gh)" >&2
    exit 1
  fi
fi

API="https://api.github.com"
AUTH_HEADER="Authorization: token $GITHUB_TOKEN"
GH_ACCEPT="Accept: application/vnd.github+json"

echo "── Repository: $GITHUB_OWNER/$GITHUB_REPO ──────────────────────────────"

# ── 1. Register Jenkins webhook ───────────────────────────────────────────────
echo ""
echo "[1/5] Registering Jenkins webhook..."
WEBHOOK_URL="http://${JENKINS_IP}:8080/github-webhook/"
WEBHOOK_RESP=$(curl -s -o /dev/null -w "%{http_code}" \
  -X POST "$API/repos/$GITHUB_OWNER/$GITHUB_REPO/hooks" \
  -H "$AUTH_HEADER" -H "$GH_ACCEPT" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  -d "{
    \"name\": \"web\",
    \"active\": true,
    \"events\": [\"push\", \"pull_request\"],
    \"config\": {
      \"url\": \"$WEBHOOK_URL\",
      \"content_type\": \"json\",
      \"insecure_ssl\": \"1\"
    }
  }")

if [[ "$WEBHOOK_RESP" == "201" ]]; then
  echo "  ✅  Webhook created → $WEBHOOK_URL"
elif [[ "$WEBHOOK_RESP" == "422" ]]; then
  echo "  ℹ️   Webhook already exists → $WEBHOOK_URL"
else
  echo "  ⚠️   Webhook returned HTTP $WEBHOOK_RESP — check token permissions"
fi

# ── Helper: set/update a GitHub Actions secret ────────────────────────────────
set_secret() {
  local name="$1"
  local value="$2"
  if command -v gh &>/dev/null; then
    echo "$value" | gh secret set "$name" --repo "$GITHUB_OWNER/$GITHUB_REPO"
    echo "  ✅  Secret $name set via gh CLI"
  else
    # Use REST API (requires libsodium encryption — gh CLI is preferred)
    echo "  ⚠️   gh CLI not found. Set secret $name manually in GitHub Settings → Secrets"
  fi
}

# ── 2. Set GitHub Actions secrets ─────────────────────────────────────────────
echo ""
echo "[2/5] Setting GitHub Actions secrets..."

# Docker Hub
[[ -n "$DOCKERHUB_USERNAME" ]] && set_secret "DOCKERHUB_USERNAME" "$DOCKERHUB_USERNAME"
[[ -n "$DOCKERHUB_TOKEN" ]]    && set_secret "DOCKERHUB_TOKEN"    "$DOCKERHUB_TOKEN"

# k3s kubeconfig — fetch live from the k3s instance
echo "      Fetching kubeconfig from k3s @ $K8S_IP ..."
K8S_KUBECONFIG=$(ssh -o StrictHostKeyChecking=no \
  -i "$SSH_KEY_PATH" \
  "ec2-user@$K8S_IP" \
  "sudo cat /etc/rancher/k3s/k3s.yaml 2>/dev/null" \
  | sed "s/127.0.0.1/$K8S_IP/g" \
  | base64 | tr -d '\n') || K8S_KUBECONFIG=""

if [[ -n "$K8S_KUBECONFIG" ]]; then
  set_secret "K8S_KUBECONFIG" "$K8S_KUBECONFIG"
  echo "  ✅  K8S_KUBECONFIG set (k3s endpoint: https://$K8S_IP:6443)"
else
  echo "  ⚠️   Could not fetch kubeconfig — k3s may still be booting. Run again in 2 min."
fi

# Ansible targets
set_secret "ANSIBLE_SSH_KEY"  "$(cat "$SSH_KEY_PATH")"
set_secret "ANSIBLE_HOST_1"   "$ANSIBLE_IP"
set_secret "ANSIBLE_HOST_2"   "$DOCKER_IP"

# GitHub token for Jenkins seed job (stored in GH secrets for Actions too)
set_secret "GITHUB_TOKEN_FARMERSMK" "$GITHUB_TOKEN"

# ── 3. Verify webhook is active ───────────────────────────────────────────────
echo ""
echo "[3/5] Verifying webhook..."
HOOKS=$(curl -s \
  "$API/repos/$GITHUB_OWNER/$GITHUB_REPO/hooks" \
  -H "$AUTH_HEADER" -H "$GH_ACCEPT")
echo "$HOOKS" | python3 -c "
import sys, json
hooks = json.load(sys.stdin)
for h in hooks:
    print(f\"  Hook #{h['id']}: {h['config'].get('url','?')} — active={h['active']}\")
" 2>/dev/null || echo "  (Install python3 to see hook list)"

# ── 4. Print Jenkins setup checklist ─────────────────────────────────────────
echo ""
echo "[4/5] Jenkins setup checklist ─────────────────────────────────────────"
echo "  Jenkins URL     : http://$JENKINS_IP:8080"
echo ""
echo "  After opening Jenkins:"
echo "    a) Get initial password:"
echo "       ssh -i $SSH_KEY_PATH ec2-user@$JENKINS_IP"
echo "       sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
echo ""
echo "    b) Install suggested plugins + Job DSL plugin"
echo ""
echo "    c) Add credentials (Manage Jenkins → Credentials → System → Global):"
echo "       ID: GITHUB_TOKEN       → Secret text  → your PAT"
echo "       ID: DOCKER_USERNAME    → Username/password → Docker Hub"
echo "       ID: DOCKER_PASSWORD    → Secret text  → Docker Hub token"
echo "       ID: ANSIBLE_SSH_KEY    → SSH private key → paste id_ed25519"
echo "       ID: K8S_KUBECONFIG     → Secret text  → base64 kubeconfig above"
echo ""
echo "    d) Create a freestyle 'farmersmk-seed' job:"
echo "       → Build → Process Job DSLs → Use the provided DSL script"
echo "       → Paste contents of: ci-cd/jenkins/seed-job.groovy"
echo "       → Save and Build Now"
echo ""
echo "    e) The multibranch pipeline 'farmersmk-pipeline' will appear"
echo "       and immediately scan the GitHub repo for branches."

# ── 5. Done ───────────────────────────────────────────────────────────────────
echo ""
echo "[5/5] Done ✅"
echo ""
echo "  Push to master → GitHub webhook → Jenkins builds → Docker push → k3s deploy"
echo ""
