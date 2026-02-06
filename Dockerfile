# OpenClaw Railway Wrapper with REST API Support
# Self-contained image that downloads OpenClaw and adds REST API endpoint
FROM node:22-bookworm

WORKDIR /app

# Copy wrapper files first
COPY package.json ./
COPY src/ ./src/

# Install wrapper dependencies
RUN npm install

# Install OpenClaw CLI and mcporter globally
RUN npm install -g openclaw@latest mcporter

# Create necessary directories
RUN mkdir -p /data/.openclaw /data/workspace /tmp/openclaw /app/config

# Create mcporter config for zirodelta MCP server
RUN echo '{"servers":{"zirodelta":{"baseUrl":"https://zdlt-mcp.up.railway.app/sse","description":"Zirodelta MCP tools","transport":"sse","headers":{}}}}' > /app/config/mcporter.json

# Environment configuration
ENV NODE_ENV=production
ENV PORT=8080
ENV OPENCLAW_STATE_DIR=/data/.openclaw
ENV OPENCLAW_WORKSPACE_DIR=/data/workspace
ENV INTERNAL_GATEWAY_PORT=18789
ENV OPENCLAW_ENTRY=/usr/local/lib/node_modules/openclaw/dist/entry.js

# The wrapper listens on 8080 and proxies to gateway on 18789
EXPOSE 8080

# Start the wrapper server
CMD ["node", "src/server.js"]
