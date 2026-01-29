# excalidraw.Dockerfile
FROM node:20 AS build

WORKDIR /app

ARG CACHE_INVALIDATOR
ARG VITE_APP_WS_SERVER_URL=https://oss-collab.excalidraw.com
ENV VITE_APP_WS_SERVER_URL=$VITE_APP_WS_SERVER_URL
RUN echo "Building using: $VITE_APP_WS_SERVER_URL"
RUN echo "Cache invalidator: $CACHE_INVALIDATOR"

# Clone the Excalidraw repo directly
RUN git clone --depth 1 https://github.com/excalidraw/excalidraw.git .

RUN npm install -g pnpm

# Set environment variables so the pnpm command is found
ENV PNPM_HOME="/usr/local/lib/node_modules/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

RUN pnpm i
RUN pnpm run build:app:docker

# Production image
FROM nginx:1.27-alpine
COPY --from=build /app/excalidraw-app/build /usr/share/nginx/html
HEALTHCHECK CMD wget -q -O /dev/null http://localhost || exit 1
