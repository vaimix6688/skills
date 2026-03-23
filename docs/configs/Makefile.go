# =============================================================================
# Project — Go Makefile (myproject-core, myproject-ingestion)
# Master copy: myproject-docs/docs/configs/Makefile.go
# =============================================================================

.PHONY: dev build test lint fmt clean setup docker-up docker-down coverage

setup:
	go mod download
	cp -n .env.example .env 2>/dev/null || true
	@echo "Run 'make docker-up' to start infrastructure"

dev:
	go run ./cmd/...

build:
	CGO_ENABLED=0 go build -o bin/ ./cmd/...

test:
	go test -race -coverprofile=coverage.out ./...
	@go tool cover -func=coverage.out | tail -1

lint:
	golangci-lint run

fmt:
	gofmt -w .
	goimports -w .

clean:
	rm -rf bin/ coverage.out

docker-up:
	docker compose up -d

docker-down:
	docker compose down

coverage:
	go test -race -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out -o coverage.html
	@echo "Open coverage.html in browser"
