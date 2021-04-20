# Install dependencies only when needed
# this image is what node:alpine is on April 16th 2021
FROM docker.io/library/node@sha256:0944bcebe7fb69f2e81080b879d68e93446d5118fb857f029c3516df25d374d9 AS deps
# Check https://github.com/nodejs/docker-node/tree/b4117f9333da4138b03a546ec926ef50a31506c3#nodealpine to understand why libc6-compat might be needed.
#RUN apk add --no-cache libc6-compat
WORKDIR /app
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile && find /app/node_modules -exec touch -t 202101010000.00 {} +

# Rebuild the source code only when needed
FROM docker.io/library/node@sha256:0944bcebe7fb69f2e81080b879d68e93446d5118fb857f029c3516df25d374d9 AS builder
ENV NODE_ENV production
ENV CIRCLE_NODE_TOTAL 1
WORKDIR /app
COPY . .
COPY --from=deps /app/node_modules /app/node_modules
RUN yarn build && rm -rf /app/.next/cache/webpack && find /app/.next -exec touch -t 202101010000.00 {} +

# Production image, copy all the files and run next
FROM docker.io/library/node@sha256:0944bcebe7fb69f2e81080b879d68e93446d5118fb857f029c3516df25d374d9 AS runner
WORKDIR /app

ENV ENV NEXT_TELEMETRY_DISABLED 1
ENV NODE_ENV production

# You only need to copy next.config.js if you are NOT using the default configuration
COPY --from=builder /app/next.config.js ./
COPY --from=builder /app/public ./public
COPY --from=builder --chown=nobody:nogroup /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

USER nobody

EXPOSE 3000

CMD ["yarn", "start"]
