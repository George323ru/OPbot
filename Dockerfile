FROM node:22-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    git cmake g++ python3 \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g openclaw

WORKDIR /app

COPY workspace/ /root/.openclaw/workspace/
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

EXPOSE 18789

ENTRYPOINT ["/app/entrypoint.sh"]
