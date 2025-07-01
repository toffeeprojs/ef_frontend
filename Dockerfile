FROM node:24.3.0-alpine3.21 AS builder

WORKDIR /app

RUN corepack enable

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
RUN pnpm install --frozen-lockfile

COPY public \
     src \
     eslint.config.mjs \
     next.config.ts \
     package.json \
     pnpm-lock.yaml \
     pnpm-workspace.yaml \
     postcss.config.mjs \
     tsconfig.json ./
RUN pnpm build


FROM nginx:1.28.0-alpine3.21-slim

RUN apk add --no-cache curl

RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf

RUN rm -rf /usr/share/nginx/html/*
COPY --from=builder /app/out /usr/share/nginx/html

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/ || exit 1
