unifi-detector
==============

Detect new clients on a UniFi network and report changes to an MQTT topic.

Since the UniFi controller itself does not yet support MQTT notifications, this utility will poll the UniFi controller and issue a message to an MQTT broker every time a new client joins the network. You can additionally configure how long until a client should be considered disconnected (lifespan).

I have found this useful for both home automation and some very basic security alerts. For example, if a new client is detected on the WiFi, I'm able to receive a push notification (triggered via the MQTT broker) and manually determine if they belong on the network or not.

## Installation

Choose one of the following options:

```bash
git clone github.com/scraton/unifi-detector
cd unifi-detector
make build-docker
docker container run unifi-detector:latest

# ...or...

mkdir -p $GOPATH/src/github.com/scraton
cd $GOPATH/src/github.com/scraton
git clone github.com/scraton/unifi-detector
cd unifi-detector
make install
```

## Usage

Here is the most basic example providing just the required fields:

```bash
unifi-detector -api-address="https://unifi:8443" -mqtt-address="tcp://mosquitto:1883" -mqtt-topic "unifi/network/detector"
```

Although most of the time you will be dealing with self signed certificates and username/password combinations. You can specify all of this on the command line, or use environment variables. It is recommended to use a read only account for the UniFi API.

```bash
export UNIFI_API_PASSWORD=secret
export UNIFI_MQTT_PASSWORD=secret

unifi-detector -api-address="https://unifi:8443" \
               -api-username="detector" \
               -api-insecure \
               -mqtt-address="tcp://mosquitto:1883" \
               -mqtt-username="detector" \
               -mqtt-topic "unifi/network/detector"
```

All command line flags can be specified in the environment. Just prefix with `UNIFI_` and replace `-` with `_`.

You can use `unifi-detector -h` to get a full summary of available command parameters.

## Development

```bash
git clone github.com/scraton/unifi-detector
cd unifi-detector
make dev deps
```
