BINARY=unifi-detector
PKG=github.com/scraton/unifi-detector
VERSION=$(shell git describe --tags --always --dirty)
LD_FLAGS="-X main.programVersion=$(VERSION)"

all: deps build
build:
	go build -a -ldflags $(LD_FLAGS) ./...
build-linux:
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -installsuffix cgo -ldflags $(LD_FLAGS) -o $(BINARY) ./...
build-docker:
	docker build -t unifi-detector:latest .
install: all
	sudo mv unifi-detector /usr/local/bin/unifi-detector
clean:
	go clean -x
	rm -f bin/$(BINARY)
run:
	./bin/$(BINARY)
deps:
	go get -u github.com/sirupsen/logrus
	go get -u github.com/mdlayher/unifi
	go get -u github.com/muesli/cache2go
	go get -u github.com/namsral/flag
	go get -u github.com/eclipse/paho.mqtt.golang

# Dev Tools list is per MS documentation here: https://github.com/Microsoft/vscode-go/wiki/Go-tools-that-the-Go-extension-depends-on
dev:
	go get -u github.com/ramya-rao-a/go-outline \
		github.com/acroca/go-symbols \
		github.com/nsf/gocode \
		github.com/rogpeppe/godef \
		github.com/golang/lint/golint \
		github.com/fatih/gomodifytags \
		github.com/tpng/gopkgs \
		golang.org/x/tools/cmd/gorename \
		github.com/cweill/gotests/... \
		golang.org/x/tools/cmd/guru \
		github.com/josharian/impl \
		sourcegraph.com/sqs/goreturns \
		golang.org/x/tools/cmd/godoc \
		github.com/zmb3/gogetdoc
