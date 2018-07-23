FROM alpine
ADD dist/unifi-detector /opt/app/
ADD container/files /
RUN apk add --update ca-certificates openssl bash && update-ca-certificates && \
  wget -q -O /usr/local/bin/confd https://github.com/kelseyhightower/confd/releases/download/v0.11.0/confd-0.11.0-linux-amd64 && \
  chmod +x /usr/local/bin/confd

WORKDIR /opt/app
ENTRYPOINT ["/opt/app/start.sh"]
