FROM node:20-bookworm-slim

WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends ffmpeg ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY package*.json ./
RUN npm ci --ignore-scripts --omit=dev

COPY . .

ENV NODE_ENV=production
ENV PORT=5000

RUN mkdir -p /app/session /app/data /app/tmp

EXPOSE 5000

CMD ["node", "index.js"]

VOLUME ["/app/session", "/app/data"]

HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
  CMD node -e "fetch('http://127.0.0.1:' + (process.env.PORT || 5000)).then(r => process.exit(r.ok ? 0 : 1)).catch(() => process.exit(1))"
