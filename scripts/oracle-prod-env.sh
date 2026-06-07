#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$ROOT_DIR/.env"
ORACLE_PUBLIC_IP="${ORACLE_PUBLIC_IP:-141.148.213.89}"
API_HOST="${API_HOST:-api.${ORACLE_PUBLIC_IP}.sslip.io}"
ADMIN_HOST="${ADMIN_HOST:-admin.${ORACLE_PUBLIC_IP}.sslip.io}"

if [[ -f "$ENV_FILE" && "${1:-}" != "--force" ]]; then
  echo ".env already exists."
  echo "Keeping it untouched. Re-run with --force only if you want to replace it."
  exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "docker is required before generating the Caddy password hash."
  exit 1
fi

read -r -p "Admin username [parth]: " ADMIN_USER
ADMIN_USER="${ADMIN_USER:-parth}"

read -s -r -p "Admin password for Caddy + admin login: " ADMIN_PASSWORD
echo
if [[ -z "$ADMIN_PASSWORD" ]]; then
  echo "Admin password cannot be empty."
  exit 1
fi

read -r -p "Setup code [KAJU-2026]: " ADMIN_SETUP_CODE
ADMIN_SETUP_CODE="${ADMIN_SETUP_CODE:-KAJU-2026}"

read -r -p "AI provider [openai]: " AI_PROVIDER
AI_PROVIDER="${AI_PROVIDER:-openai}"

read -s -r -p "OpenAI API key: " OPENAI_API_KEY
echo

read -s -r -p "Groq API key optional: " GROQ_API_KEY
echo

DB_PASSWORD="$(openssl rand -hex 24)"
JWT_SECRET="$(openssl rand -hex 32)"
RAW_HASH="$(docker run --rm caddy:2-alpine caddy hash-password --plaintext "$ADMIN_PASSWORD")"
ADMIN_PASS_HASH="$(printf '%s' "$RAW_HASH" | sed 's/\$/$$/g')"

umask 077
cat > "$ENV_FILE" <<EOF
COMPOSE_PROJECT_NAME=kajupilot
DEPLOY_TARGET=production
DB_PASSWORD=$DB_PASSWORD
JWT_SECRET=$JWT_SECRET
ADMIN_SETUP_CODE=$ADMIN_SETUP_CODE
ADMIN_SECRET=$ADMIN_PASSWORD
ADMIN_USER=$ADMIN_USER
ADMIN_PASS_HASH=$ADMIN_PASS_HASH
API_HOST=$API_HOST
ADMIN_HOST=$ADMIN_HOST
ADMIN_API_URL=http://api:3000/api/v1
NEXT_PUBLIC_API_URL=https://$API_HOST/api/v1
ALLOWED_ORIGINS=https://$ADMIN_HOST
AI_PROVIDER=$AI_PROVIDER
OPENAI_API_KEY=$OPENAI_API_KEY
OPENAI_MODEL=gpt-4o-mini
OPENAI_INPUT_COST_PER_1M=0.15
OPENAI_OUTPUT_COST_PER_1M=0.60
GROQ_API_KEY=$GROQ_API_KEY
GROQ_MODEL=meta-llama/llama-4-scout-17b-16e-instruct
GROQ_INPUT_COST_PER_1M=0.11
GROQ_OUTPUT_COST_PER_1M=0.34
AI_MAX_TOKENS=700
AI_TEMPERATURE=0.2
AI_PARSE_RATE_LIMIT_PER_HOUR=20
EOF

echo "Wrote $ENV_FILE"
echo "API:   https://$API_HOST/api/v1"
echo "Admin: https://$ADMIN_HOST"
