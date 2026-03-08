# DNYFappbuilder — Node.js Production Dockerfile
# Usage (from repo root): docker build -f docker/nodejs.Dockerfile -t myapp .
# Usage (from your project): docker build -t myapp .  (copy this file as Dockerfile)
FROM node:20-alpine AS builder

WORKDIR /app

# Support both repo-root builds (CI) and project-level builds
COPY examples/nodejs-api/package*.json ./
RUN npm install --omit=dev && npm cache clean --force
COPY examples/nodejs-api/ .

# ── Production stage ──────────────────────────────────────
FROM node:20-alpine AS production

RUN apk add --no-cache tini

WORKDIR /app

COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/src ./src
COPY --from=builder /app/package.json ./

RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001
USER nodejs

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD wget -qO- http://localhost:3000/health || exit 1

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["node", "src/index.js"]
