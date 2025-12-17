# Build stage
FROM golang:1.23-alpine AS builder

WORKDIR /app

# Install build dependencies
RUN apk add --no-cache git

# Copy go mod files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o server ./cmd/server

# Final stage
FROM alpine:3.19

WORKDIR /app

# Install runtime dependencies
RUN apk --no-cache add ca-certificates tzdata wget

# Set timezone
ENV TZ=Asia/Jakarta

# Copy binary from builder
COPY --from=builder /app/server .
COPY --from=builder /app/config ./config
COPY --from=builder /app/migrations ./migrations

# Create storage directory
RUN mkdir -p /app/storage/uploads

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/api/v1/health || exit 1

# Run the application
CMD ["./server"]
