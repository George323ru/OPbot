FROM node:22-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    git openssh-client ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*

# Заставляем git использовать HTTPS вместо SSH
RUN git config --global url."https://github.com/".insteadOf "ssh://git@github.com/" \
    && git config --global url."https://github.com/".insteadOf "git@github.com:"

# Устанавливаем без компиляции node-llama-cpp (не нужен для OpenRouter)
RUN npm install -g --ignore-scripts openclaw

# Удаляем llama-cpp чтобы не загружался при старте
RUN rm -rf /usr/local/lib/node_modules/openclaw/node_modules/node-llama-cpp/llama \
    /usr/local/lib/node_modules/openclaw/node_modules/node-llama-cpp/bins

WORKDIR /app

COPY workspace/ /root/.openclaw/workspace/
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

EXPOSE 18789

ENTRYPOINT ["/app/entrypoint.sh"]
