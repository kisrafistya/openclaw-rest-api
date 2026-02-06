# OpenClaw Railway Template with Delta Agent + Zirodelta MCP
# Complete setup with REST API, MCP tools, and Delta persona
FROM node:22-bookworm

WORKDIR /app

# Install global dependencies first
RUN npm install -g openclaw@latest mcporter tsx typescript

# Copy wrapper files
COPY package.json ./
COPY src/ ./src/

# Install wrapper dependencies
RUN npm install

# Create necessary directories
RUN mkdir -p /data/.openclaw /data/workspace /tmp/openclaw /app/config

# Clone and set up zirodelta-mcp for STDIO transport
RUN git clone --depth 1 https://github.com/Zirodelta/zirodelta-mcp.git /app/zirodelta-mcp
WORKDIR /app/zirodelta-mcp
RUN npm install && npm install -D @types/node

# Patch the API URL to use trailing slash (fixes HTTP 307 redirect issue)
RUN sed -i 's|https://api.zirodelta.xyz/jsonrpc|https://api.zirodelta.xyz/jsonrpc/|g' src/index.ts

# Patch null handling in response (fixes MCP validation error)
RUN sed -i 's/text: JSON.stringify(result, null, 2),/text: result !== undefined \&\& result !== null ? JSON.stringify(result, null, 2) : "No data returned",/g' src/index.ts

WORKDIR /app

# Create mcporter config for STDIO transport
RUN echo '{"mcpServers":{"zirodelta":{"command":"tsx","args":["/app/zirodelta-mcp/src/index.ts"],"env":{"ZIRODELTA_API_URL":"https://api.zirodelta.xyz/jsonrpc/"}}}}' > /app/config/mcporter.json

# Copy Delta agent persona files to workspace
COPY persona/ /data/workspace/

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
