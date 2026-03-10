FROM node:22-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    git cmake g++ python3 openssh-client ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*

# Заставляем git использовать HTTPS вместо SSH (нет SSH-ключей в контейнере)
RUN git config --global url."https://github.com/".insteadOf "ssh://git@github.com/" \
    && git config --global url."https://github.com/".insteadOf "git@github.com:"

RUN npm install -g openclaw

WORKDIR /app

COPY workspace/ /root/.openclaw/workspace/
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

EXPOSE 18789

ENTRYPOINT ["/app/entrypoint.sh"]
