# build
FROM golang:1.17.2-alpine3.14 AS build
WORKDIR /app
RUN apk --no-cache add -t build-deps build-base make git curl ca-certificates

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN make build

# runtime
FROM alpine:3.14
RUN apk --no-cache add ca-certificates
COPY --from=build /app/bin/unifi-detector /usr/local/bin/unifi-detector
CMD ["unifi-detector"]
