# multistage - builder image
FROM node:alpine AS builder
WORKDIR /app

RUN apk update && apk upgrade && \
    apk add --no-cache bash git openssh

RUN git clone https://github.com/GRVYDEV/Lightspeed-react.git
WORKDIR /app/Lightspeed-react
RUN npm install

# configure ip, hardcoded to webrtc container address (8080) for now
RUN sed -i "s|stream.gud.software|lightspeed-webrtc |g" src/wsUrl.js

# build it
RUN npm run build

# runtime image
FROM node:alpine
WORKDIR /app/
COPY --from=builder /app/Lightspeed-react/build ./build/
RUN npm install -g serve
EXPOSE 80
CMD serve -s build -l 80