#!/bin/sh
set -e

CONFIG_FILE="/root/.openclaw/openclaw.json"
mkdir -p /root/.openclaw

# Генерируем конфиг из переменных окружения
cat > "$CONFIG_FILE" <<EOF
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "${MODEL:-openrouter/google/gemini-3.1-flash-lite-preview}"
      },
      "workspace": "/root/.openclaw/workspace",
      "compaction": { "mode": "safeguard" },
      "maxConcurrent": 4,
      "subagents": { "maxConcurrent": 8 }
    }
  },
  "tools": {
    "profile": "coding",
    "web": { "search": { "provider": "brave" } }
  },
  "session": { "dmScope": "per-channel-peer" },
  "channels": {
    "telegram": {
      "enabled": true,
      "dmPolicy": "pairing",
      "botToken": "${TELEGRAM_BOT_TOKEN}",
      "groupPolicy": "${TELEGRAM_GROUP_POLICY:-open}",
      "streaming": "partial"
    }
  },
  "gateway": {
    "port": 18789,
    "mode": "local",
    "bind": "lan",
    "auth": {
      "mode": "token",
      "token": "${GATEWAY_TOKEN}"
    }
  },
  "plugins": {
    "entries": {
      "telegram": { "enabled": true }
    }
  }
}
EOF

# Записываем OpenRouter API ключ если передан
if [ -n "$OPENROUTER_API_KEY" ]; then
  mkdir -p /root/.openclaw/credentials
  cat > /root/.openclaw/credentials/openrouter-default.json <<CREDS
{ "apiKey": "${OPENROUTER_API_KEY}" }
CREDS
fi

echo "Starting OpenClaw gateway..."
export NODE_OPTIONS="--max-old-space-size=512"
exec openclaw gateway
