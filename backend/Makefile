.PHONY: build run test migrate seed dev clean

# Build the application
build:
	go build -o bin/server ./cmd/server

# Run the application
run:
	go run ./cmd/server

# Run with hot reload (requires air)
dev:
	air -c .air.toml

# Run tests
test:
	go test -v -cover ./...

# Run seeder
seed:
	go run ./cmd/seed

# Download dependencies
deps:
	go mod download
	go mod tidy

# Clean build artifacts
clean:
	rm -rf bin/

# Build for production
build-prod:
	CGO_ENABLED=0 GOOS=linux go build -o bin/server ./cmd/server

# Format code
fmt:
	gofmt -w .

# Run linter (requires golangci-lint)
lint:
	golangci-lint run

# Generate API documentation (requires swag)
docs:
	swag init -g cmd/server/main.go -o docs
