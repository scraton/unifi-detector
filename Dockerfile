# build
FROM golang:alpine AS build
WORKDIR /app
RUN apk --no-cache add -t build-deps build-base make git curl \
 && apk --no-cache add ca-certificates

COPY Makefile .
RUN make deps
COPY . .
RUN make build-linux

# runtime
FROM alpine
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build /app/unifi-detector .
ENV PATH /
CMD ["/unifi-detector"]
