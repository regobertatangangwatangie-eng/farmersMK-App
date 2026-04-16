# Stage 1: build React/Vite app
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci --legacy-peer-deps
RUN npm rebuild esbuild
COPY . .
ARG VITE_API_BASE_URL=http://localhost:8080
ARG VITE_REALTIME_URL=ws://localhost:8080/ws
ARG VITE_SERVICE_HUB_URL=http://localhost/services.html
ENV VITE_API_BASE_URL=$VITE_API_BASE_URL
ENV VITE_REALTIME_URL=$VITE_REALTIME_URL
ENV VITE_SERVICE_HUB_URL=$VITE_SERVICE_HUB_URL
RUN npm run build

# Stage 2: serve with nginx
FROM nginx:1.27-alpine
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
