GOPATH := $(shell pwd)

export GOPATH

APP_NAME=unifi-detector
VERSION=1.0.0
COMMIT=$(shell git rev-parse --short HEAD || echo '0000000')
TS=$(shell date -u +%Y-%m-%dT%H%M%S)

LD_FLAGS="-X main.programName=$(APP_NAME) -X main.buildTimestamp=$(TS) -X main.programVersion=$(VERSION) -X main.gitCommit=$(COMMIT)"

PATH := $(PATH):$(GOPATH)/bin

.DEFAULT_GOAL := dist

clean:
	rm -rf dist pkg bin
	find src -type d -maxdepth 1 -not -name "git.home.lan/scraton" -not -name src -exec rm -rf {} \;

.PHONY: install-build-deps
install-build-deps:
	# go get your app's functional dependencies here...
	go get -u github.com/sirupsen/logrus
	go get -u github.com/mdlayher/unifi
	go get -u github.com/muesli/cache2go
	go get -u github.com/namsral/flag

.PHONY: install
install:
	go install -ldflags $(LD_FLAGS) git.home.lan/scraton/unifi-detector

.PHONY: build
build:
	go build -a -o dist/$(APP_NAME) -ldflags $(LD_FLAGS) git.home.lan/scraton/unifi-detector

.PHONY: docker
docker:
	docker build \
	  --build-arg BUILD_TIMESTAMP=$(TS) \
	  --build-arg BUILD_VERSION=$(VERSION) \
	  --build-arg BUILD_REVISION=$(COMMIT) \
	  -t unifi-detector:latest .

# Dev Tools list is per MS documentation here: https://github.com/Microsoft/vscode-go/wiki/Go-tools-that-the-Go-extension-depends-on
.PHONY: install-dev-tools
install-dev-tools:
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
