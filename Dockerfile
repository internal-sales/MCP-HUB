# Stage 1: Build the Dashboard UI
FROM node:22-alpine AS ui-builder
WORKDIR /app
# Copy the entire repository so Vite can access root folders like /assets
COPY . .
RUN cd web/dashboard && npm ci
RUN cd web/dashboard && npm run build

# Stage 2: Build the Go binary
FROM golang:1.24.3 AS go-builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
# Create the dist folder and copy the compiled UI into it
RUN mkdir -p internal/dashboardui/dist
COPY --from=ui-builder /app/web/dashboard/dist ./internal/dashboardui/dist

# Build the final binary
RUN CGO_ENABLED=0 GOOS=linux go build -o mcpjungle .

# Stage 3: Create the final lightweight container
FROM gcr.io/distroless/base:latest
LABEL org.opencontainers.image.source="https://github.com/mcpjungle/mcpjungle"
LABEL org.opencontainers.image.title="MCPJungle"
COPY --from=go-builder /app/mcpjungle /mcpjungle
EXPOSE 8080
ENTRYPOINT ["/mcpjungle"]
CMD ["start", "--host", "0.0.0.0"]
