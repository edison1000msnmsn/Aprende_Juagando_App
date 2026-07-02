FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
COPY backend/package.json backend/package.json
RUN npm ci
COPY backend backend
COPY database database
COPY content content
RUN npm run db:generate && npm run build:api

FROM node:20-alpine AS runtime
WORKDIR /app
ENV NODE_ENV=production
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/backend/dist ./backend/dist
COPY --from=build /app/backend/package.json ./backend/package.json
COPY --from=build /app/database ./database
COPY --from=build /app/content ./content
COPY package.json package-lock.json ./
EXPOSE 3000
CMD ["node", "backend/dist/main.js"]
