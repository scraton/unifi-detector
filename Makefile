GOPATH := $(shell pwd)

export GOPATH

APP_NAME=unifi-detector
VERSION=1.0.0
COMMIT=$(shell git rev-parse --short HEAD || echo '0000000')
TS=$(shell date -u +%Y-%m-%dT%H%M%S)
SRCDIR="git.home.lan/scraton/unifi-detector"

LD_FLAGS="-X main.programName=$(APP_NAME) -X main.buildTimestamp=$(TS) -X main.programVersion=$(VERSION) -X main.gitCommit=$(COMMIT)"

PATH := $(PATH):$(GOPATH)/bin

all: deps build
build:
	go build -a -o bin/$(APP_NAME) -ldflags $(LD_FLAGS) -v $(SRCDIR)
build-linux:
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -installsuffix cgo -ldflags $(LD_FLAGS) -o $(APP_NAME) $(SRCDIR)
build-docker:
	docker build -t unifi-detector:latest .
clean:
	go clean -x
	rm -f bin/$(APP_NAME)
run:
	./bin/$(APP_NAME)
deps:
	go get -u github.com/sirupsen/logrus
	go get -u github.com/mdlayher/unifi
	go get -u github.com/muesli/cache2go
	go get -u github.com/namsral/flag

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
