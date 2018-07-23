# build
FROM golang:alpine AS build
WORKDIR /app
COPY ./src/git.home.lan/scraton/unifi-detector/ .
RUN apk --no-cache add -t build-deps build-base git curl \
 && apk --no-cache add ca-certificates \
 && go get -u github.com/sirupsen/logrus \
 && go get -u github.com/mdlayher/unifi \
 && go get -u github.com/muesli/cache2go \
 &&	go get -u github.com/namsral/flag

ARG BUILD_TIMESTAMP
ARG BUILD_VERSION
ARG BUILD_REVISION
ENV LD_FLAGS="-X main.programName=unifi-detector -X main.buildTimestamp=${BUILD_TIMESTAMP} -X main.programVersion=${BUILD_VERISON} -X main.gitCommit=${BUILD_REVISION}"
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags "${LD_FLAGS}" -o unifi-detector .

# runtime
FROM alpine
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build /app/unifi-detector .
CMD ["/unifi-detector"]
