# Stage 1: Build the Go binary
FROM golang:1.23 AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o mcpjungle .

# Stage 2: Create the final container
FROM gcr.io/distroless/base:latest
LABEL org.opencontainers.image.source="https://github.com/mcpjungle/mcpjungle"
LABEL org.opencontainers.image.title="MCPJungle"
COPY --from=builder /app/mcpjungle /mcpjungle
EXPOSE 8080
ENTRYPOINT ["/mcpjungle"]
CMD ["start"]
