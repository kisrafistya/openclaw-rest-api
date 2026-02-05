# OpenClaw Railway Template with REST API Support
# This image is based on the original OpenClaw railway template but adds
# an OpenAI-compatible /v1/chat/completions REST endpoint

FROM ghcr.io/openclawai/openclaw:railway

WORKDIR /app

# Copy the modified wrapper with REST API endpoint
COPY src/server.js /app/src/server.js
COPY src/setup-app.js /app/src/setup-app.js
COPY package.json /app/package.json

# Install wrapper dependencies  
RUN npm install

# Environment configuration
ENV OPENCLAW_PUBLIC_PORT=8080
ENV INTERNAL_GATEWAY_PORT=18789
ENV NODE_ENV=production

# The wrapper listens on 8080 and proxies to gateway on 18789
EXPOSE 8080

# Start the wrapper server
CMD ["node", "src/server.js"]
