ARG ALPINE_VERSION=3.12
ARG NODE_VERSION=15
ARG NGINX_VERSION=1.19.6

FROM node:${NODE_VERSION}-alpine${ALPINE_VERSION} AS builder
WORKDIR /app/Lightspeed-react
COPY package.json package-lock.json ./
RUN npm install
COPY . .
RUN npm run build


FROM nginx:${NGINX_VERSION}-alpine
ENV WEBSOCKET_HOST=localhost
ENV WEBSOCKET_PORT=8080
EXPOSE 80/tcp
COPY --chown=1000 docker/entrypoint.sh /docker-entrypoint.d/entrypoint.sh
COPY --chown=1000 docker/config.json.template /config.json.template
COPY --from=builder --chown=1000 /app/Lightspeed-react/build /usr/share/nginx/html
