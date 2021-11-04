BINARY=unifi-detector
PKG=github.com/scraton/unifi-detector
VERSION=$(shell git describe --tags --always --dirty)
LD_FLAGS="-X main.programVersion=$(VERSION)"

build:
	CGO_ENABLED=0 go build -a -installsuffix cgo -ldflags $(LD_FLAGS) -o bin/$(BINARY) ./...
build-docker:
	docker build -t unifi-detector:$(VERSION) .
install: build
	sudo mv bin/unifi-detector /usr/local/bin/unifi-detector
clean:
	go clean -x
	rm -f bin/
run:
	./bin/$(BINARY)
