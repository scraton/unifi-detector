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
	# eg: go get -u golang.org/x/net/context
	go get -u github.com/sirupsen/logrus
	go get -u github.com/mdlayher/unifi
	go get -u github.com/muesli/cache2go
	go get -u github.com/namsral/flag

.PHONY: install
install:
	go install -ldflags $(LD_FLAGS) git.home.lan/scraton/unifi-detector

.PHONY: dist-app
dist-app:
	GOOS=linux GOARCH=amd64 go build -a -o dist/$(APP_NAME) -ldflags $(LD_FLAGS) git.home.lan/scraton/unifi-detector

.PHONY: dist
dist: dist-app
	docker-compose build

.PHONY: deploy-local
deploy-local: dist
	docker stack deploy -c docker-compose.yml unifi-detector

.PHONY: run-local
run-local:
	docker-compose up

.PHONY: clean-docker
clean-docker:
	docker stack rm unifi-detector
	docker ps -a -f status=exited -q | xargs docker rm
	docker images -f dangling=true -q | xargs docker rmi

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
