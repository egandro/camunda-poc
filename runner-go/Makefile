.PHONY: build
build:
	go mod tidy
	GOOS=linux GOARCH=amd64 go build $(LDFLAGS) -o ./worker ./cmd/worker
	GOOS=linux GOARCH=amd64 go build $(LDFLAGS) -o ./starter ./cmd/starter
