
# -------- Dependencies --------
FROM node:20-alpine AS builder

ENV http_proxy=http://10.190.21.24:3128
ENV https_proxy=http://10.190.21.24:3128
ENV no_proxy=localhost,127.0.0.1,.bankmega.com
ENV HTTP_PROXY=http://10.190.21.24:3128
ENV HTTPS_PROXY=http://10.190.21.24:3128
ENV NO_PROXY=localhost,127.0.0.1,.bankmega.com

WORKDIR /app

# COPY package.json package-lock.json* pnpm-lock.yaml* yarn.lock* ./
COPY package.json package-lock.json ./
COPY app ./app
# COPY pages ./pages
COPY public ./public
COPY next.config.ts ./
COPY tsconfig.json ./
COPY instrumentation.ts ./

RUN \
  if [ -f package-lock.json ]; then npm ci; \
  elif [ -f pnpm-lock.yaml ]; then corepack enable && pnpm install --frozen-lockfile; \
  elif [ -f yarn.lock ]; then yarn install --frozen-lockfile; \
  else npm install; \
  fi

RUN npm install
RUN npm run build

# -------- Runner --------
FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

# OpenTelemetry defaults (override in docker-compose / k8s)
ENV OTEL_SERVICE_NAME=nextjs-app
ENV OTEL_EXPORTER_OTLP_ENDPOINT=http://10.190.13.52:4318/v1/traces

# Non-root user (security best practice)
RUN addgroup -g 1001 -S nodejs && adduser -S nextjs -u 1001
USER nextjs

COPY --from=builder /app/public ./public
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

EXPOSE 3000

CMD ["node", "node_modules/next/dist/bin/next", "start", "-p", "3000"]


# docker build -t next-js-16:dev-0.0.1 .