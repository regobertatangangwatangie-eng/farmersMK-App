#!/bin/bash
# Configure Jenkins: install plugins + set credentials
set -e

JENKINS_URL="http://localhost:8080"
AUTH="admin:FarmersMK2026!"
CLI="java -jar ~/jenkins-cli.jar -s $JENKINS_URL -auth $AUTH"

echo "=== Configuring Jenkins URL ==="
CRUMB=$(curl -sf -u "$AUTH" "$JENKINS_URL/crumbIssuer/api/json" | python3 -c "import sys,json;d=json.load(sys.stdin);print(d['crumbRequestField']+':'+d['crumb'])" 2>/dev/null || echo "")

# Fix Jenkins URL via script console
curl -sf -X POST -u "$AUTH" \
  ${CRUMB:+-H "$CRUMB"} \
  "$JENKINS_URL/scriptText" \
  --data-urlencode 'script=
import jenkins.model.*
def j = Jenkins.getInstance()
def jlc = j.getDescriptorByType(jenkins.model.JenkinsLocationConfiguration.class)
jlc.setUrl("http://'"$(curl -sf http://169.254.169.254/latest/meta-data/public-hostname)"':8080/")
jlc.save()
println("URL set: " + jlc.getUrl())
' 2>&1 | grep -v "^$" | head -5

echo ""
echo "=== Installing plugins ==="
# Core plugins needed
PLUGINS=(
  "git"
  "github"
  "github-branch-source"
  "pipeline-job"
  "workflow-aggregator"
  "job-dsl"
  "credentials"
  "credentials-binding"
  "ssh-credentials"
  "plain-credentials"
  "docker-workflow"
  "ansicolor"
  "timestamper"
  "pipeline-stage-view"
)

for plugin in "${PLUGINS[@]}"; do
  echo -n "  Installing $plugin... "
  $CLI install-plugin "$plugin" -restart 2>/dev/null || echo "already installed or failed"
done

echo "=== Restarting Jenkins safely ==="
curl -sf -X POST -u "$AUTH" ${CRUMB:+-H "$CRUMB"} "$JENKINS_URL/safeRestart" || true
sleep 30

# Wait for Jenkins to come back
for i in $(seq 1 20); do
  if curl -sf "$JENKINS_URL/login" -o /dev/null 2>/dev/null; then
    echo "Jenkins back online!"
    break
  fi
  echo "  Waiting ($((i*3))s)..."
  sleep 3
done

echo "=== Setting up credentials ==="
CRUMB=$(curl -sf -u "$AUTH" "$JENKINS_URL/crumbIssuer/api/json" | python3 -c "import sys,json;d=json.load(sys.stdin);print(d['crumbRequestField']+':'+d['crumb'])" 2>/dev/null || echo "")

# GITHUB_TOKEN credential
curl -sf -X POST -u "$AUTH" \
  ${CRUMB:+-H "$CRUMB"} \
  "$JENKINS_URL/scriptText" \
  --data-urlencode "script=
import jenkins.model.*
import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.domains.*
import org.jenkinsci.plugins.plaincredentials.impl.*
import hudson.util.Secret
def store = Jenkins.getInstance().getExtensionList('com.cloudbees.plugins.credentials.SystemCredentialsProvider')[0].getStore()
def domain = Domain.global()
// Remove existing if any
store.getCredentials(domain).findAll { it.id in ['GITHUB_TOKEN','DOCKER_USERNAME','DOCKER_PASSWORD','ANSIBLE_SSH_KEY','ANSIBLE_HOST_1','ANSIBLE_HOST_2','K8S_KUBECONFIG'] }.each { store.removeCredentials(domain, it) }
// GITHUB_TOKEN
store.addCredentials(domain, new StringBinding(CredentialsScope.GLOBAL, 'GITHUB_TOKEN', 'GitHub PAT', Secret.fromString('GITHUB_PAT_VALUE')))
// DOCKER_USERNAME
store.addCredentials(domain, new StringBinding(CredentialsScope.GLOBAL, 'DOCKER_USERNAME', 'Docker Hub username', Secret.fromString('regobert2004')))
// DOCKER_PASSWORD
store.addCredentials(domain, new StringBinding(CredentialsScope.GLOBAL, 'DOCKER_PASSWORD', 'Docker Hub token', Secret.fromString('DOCKER_TOKEN_VALUE')))
// ANSIBLE_HOST_1
store.addCredentials(domain, new StringBinding(CredentialsScope.GLOBAL, 'ANSIBLE_HOST_1', 'Ansible host 1', Secret.fromString('ANSIBLE_HOST_1_VALUE')))
// ANSIBLE_HOST_2
store.addCredentials(domain, new StringBinding(CredentialsScope.GLOBAL, 'ANSIBLE_HOST_2', 'Ansible host 2', Secret.fromString('ANSIBLE_HOST_2_VALUE')))
println('Credentials set OK')
" 2>&1 | head -5

echo "=== Done ==="
