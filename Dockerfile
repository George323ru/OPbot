FROM node:22-alpine

RUN npm install -g openclaw

WORKDIR /app

COPY workspace/ /root/.openclaw/workspace/
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

EXPOSE 18789

ENTRYPOINT ["/app/entrypoint.sh"]
