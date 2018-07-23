go-unifi-detector
=================

Detect new clients on a UniFi network and report changes to an MQTT topic.

Since the UniFi controller itself does not yet support MQTT notifications, this utility will poll the UniFi controller and issue a message to an MQTT broker every time a new client joins the network. You can additionally configure how long until a client should be considered disconnected (lifespan).

I have found this useful for both home automation and some very basic security alerts. For example, if a new client is detected on the WiFi, I'm able to receive a push notification (triggered via the MQTT broker) and manually determine if they belong on the network or not.

## Installation

Choose one of the following options:

```bash
go get -u github.com/scraton/go-unifi-detector

# ...or...

git clone github.com/scraton/go-unifi-detector
cd go-unifi-detector
make

# ...or...

git clone github.com/scraton/go-unifi-detector
cd go-unifi-detector
make build-docker
docker container run unifi-detector:latest 
```

## Usage

```bash
$ unifi-detector -h
Usage of ./bin/unifi-detector:
  -api-address string
    	Unifi Controller address
  -api-insecure
    	Allow insecure connection to Unifi Controller
  -api-password string
    	Unifi Controller password
  -api-timeout int
    	Timeout for connecting to Unfi Controller (default 60)
  -api-user string
    	Unifi Controller username
  -interval int
    	Scan interval in seconds (default 60)
  -lifespan int
    	Client cache lifespan in seconds (default 3600)
  -mqtt-address string
    	MQTT broker address
  -mqtt-password string
    	MQTT broker password
  -mqtt-topic string
    	MQTT broker topic
  -mqtt-user string
    	MQTT broker username
```

It is recommended you use a read only account for the UniFi API.

## Development

```bash
git clone github.com/scraton/go-unifi-detector
cd go-unifi-detector
make dev deps
```
