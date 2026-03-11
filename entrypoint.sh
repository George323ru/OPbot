#!/bin/sh
set -e

CONFIG_FILE="/root/.openclaw/openclaw.json"
mkdir -p /root/.openclaw

# Чистим старое состояние чтобы не раздувать память
rm -rf /root/.openclaw/openclaw.json.bak
rm -rf /root/.openclaw/sessions
rm -rf /root/.openclaw/canvas
rm -rf /tmp/openclaw

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
      "maxConcurrent": 1,
      "subagents": { "maxConcurrent": 1 }
    }
  },
  "tools": {
    "profile": "coding",
    "web": { "fetch": { "enabled": true } },
    "shell": {
      "blocklist": [
        "openclaw *",
        "vi *", "vim *", "nano *",
        "cat */openclaw.json*",
        "echo * > */openclaw.json*"
      ]
    }
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

# Защищаем конфиг от записи (бот не сможет его менять)
chmod 444 "$CONFIG_FILE"

# Записываем OpenRouter API ключ если передан
if [ -n "$OPENROUTER_API_KEY" ]; then
  mkdir -p /root/.openclaw/credentials
  cat > /root/.openclaw/credentials/openrouter-default.json <<CREDS
{ "apiKey": "${OPENROUTER_API_KEY}" }
CREDS
fi

echo "Starting OpenClaw gateway..."
export NODE_OPTIONS="--max-old-space-size=768"
exec openclaw gateway
