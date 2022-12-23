FROM node:16-alpine as deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm install

FROM node:16-alpine as builder
WORKDIR /app
COPY . .
COPY --from=deps /app/node_modules ./node_modules
RUN npm run build && npm install --production --ignore-scripts --prefer-offline

FROM node:16-alpine as runner
WORKDIR /app
RUN addgroup -g 1001 appgroup
RUN adduser -D -u 1001 appuser -G appgroup
RUN chown -R appuser:appgroup /app
USER appuser
COPY --from=builder --chown=appuser:appgroup /app/package.json ./
COPY --from=builder --chown=appuser:appgroup /app/dist ./dist
COPY --from=builder --chown=appuser:appgroup /app/node_modules ./node_modules
CMD [ "npm", "run", "start:prod" ]
