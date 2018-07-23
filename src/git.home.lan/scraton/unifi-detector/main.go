package main

import (
	"fmt"
	"net/http"
	"os"
	"time"

	"github.com/mdlayher/unifi"
	"github.com/muesli/cache2go"
	flag "github.com/namsral/flag"
	log "github.com/sirupsen/logrus"
)

// Config provides program configuration
type Config struct {
	scanInterval   time.Duration
	clientLifespan time.Duration
}

// UnifiConfig provides authentication information for the UniFi controller
type UnifiConfig struct {
	address  string
	username string
	password string
	insecure bool
	timeout  time.Duration
}

// MqttConfig provides authentication information for the MQTT client
type MqttConfig struct {
	address  string
	username string
	password string
	topic    string
}

func newCache(name string) *cache2go.CacheTable {
	return cache2go.Cache(name)
}

func newClient(config UnifiConfig) (*unifi.Client, error) {
	httpClient := &http.Client{Timeout: config.timeout}
	if config.insecure {
		httpClient = unifi.InsecureHTTPClient(config.timeout)
	}

	client, err := unifi.NewClient(config.address, httpClient)
	if err != nil {
		return nil, fmt.Errorf("cannot create UniFi controller client: %v", err)
	}
	client.UserAgent = "git.home.lan/scraton/unifi-detector"

	if err := client.Login(config.username, config.password); err != nil {
		return nil, fmt.Errorf("failed to authenticate to UniFi controller: %v", err)
	}

	return client, err
}

func pollClients(config *Config, client *unifi.Client, cache *cache2go.CacheTable) {
	for range time.Tick(config.scanInterval) {
		go evaluateClients(config, client, cache, false)
	}
}

func initializeClientsCache(config *Config, client *unifi.Client, cache *cache2go.CacheTable) {
	evaluateClients(config, client, cache, true)
}

func evaluateClients(config *Config, client *unifi.Client, cache *cache2go.CacheTable, firstRun bool) {
	clients, err := client.Stations("default")
	if err != nil {
		log.Errorf("failed to fetch clients: %v\n", err)
		return
	}

	log.Infof("Fetched %v clients", len(clients))

	// Evaluate clients
	for _, c := range clients {
		cachedClient, err := cache.Value(c.MAC.String())
		if err != nil && !firstRun {
			log.WithFields(log.Fields{
				"mac":      c.MAC.String(),
				"hostname": c.Hostname,
				"ip":       c.IP.String(),
			}).Info("New client discovered")
		}

		timeSinceLastSeen := time.Now().Sub(c.LastSeen)
		if timeSinceLastSeen < config.clientLifespan {
			cache.Add(c.MAC.String(), config.clientLifespan, c)
		} else {
			log.WithFields(log.Fields{
				"mac":               c.MAC.String(),
				"hostname":          c.Hostname,
				"ip":                c.IP.String(),
				"timeSinceLastSeen": timeSinceLastSeen.String(),
			}).Info("Ignoring client; older than the lifespan")

			if cachedClient != nil {
				// ensure client is evicted
				cache.Delete(c.MAC.String())
			}
		}
	}
}

var (
	programName    string
	programVersion string
	gitCommit      string
	buildTimestamp string
	printVersion   = flag.Bool("version", false, "displays version information")
)

func main() {
	var (
		config         Config
		configLifespan int
		configInterval int
		clientTimeout  int
		clientConfig   UnifiConfig
		mqttConfig     MqttConfig
	)

	fs := flag.NewFlagSetWithEnvPrefix(os.Args[0], "UNIFI", 0)
	fs.IntVar(&configLifespan, "lifespan", 3600, "Client cache lifespan in seconds")
	fs.IntVar(&configInterval, "interval", 60, "Scan interval in seconds")

	fs.StringVar(&clientConfig.address, "api-address", "", "Unifi Controller address")
	fs.StringVar(&clientConfig.username, "api-user", "", "Unifi Controller username")
	fs.StringVar(&clientConfig.password, "api-password", "", "Unifi Controller password")
	fs.BoolVar(&clientConfig.insecure, "api-insecure", false, "Allow insecure connection to Unifi Controller")
	fs.IntVar(&clientTimeout, "api-timeout", 60, "Timeout for connecting to Unfi Controller")

	fs.StringVar(&mqttConfig.address, "mqtt-address", "", "MQTT broker address")
	fs.StringVar(&mqttConfig.username, "mqtt-user", "", "MQTT broker username")
	fs.StringVar(&mqttConfig.password, "mqtt-password", "", "MQTT broker password")
	fs.StringVar(&mqttConfig.topic, "mqtt-topic", "", "MQTT broker topic")

	e := fs.Parse(os.Args[1:])

	switch e {
	case nil:
		// do nothing
	case flag.ErrHelp:
		os.Exit(0)
	default:
		log.Fatal(e)
		os.Exit(1)
	}

	if clientConfig.address == "" {
		log.Fatal("hostname for Unifi Controller must be set")
	}

	// if mqttConfig.address == "" {
	// 	log.Fatal("hostname for MQTT broker must be set")
	// }

	// if mqttConfig.topic == "" {
	// 	log.Fatal("topic for MQTT broker must be set")
	// }

	config.scanInterval = time.Duration(configInterval) * time.Second
	config.clientLifespan = time.Duration(configLifespan) * time.Second
	clientConfig.timeout = time.Duration(clientTimeout) * time.Second

	versionString := fmt.Sprintf("%s version:%s commit:%s timestamp:%s", programName, programVersion, gitCommit, buildTimestamp)
	if *printVersion {
		fmt.Println(versionString)
		os.Exit(0)
	}

	log.Info(versionString)

	cache := newCache("unifi_clients")
	client, err := newClient(clientConfig)
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	} else {
		log.Infof("Successfully connected to UniFi at %v", clientConfig.address)
	}

	// fetch initial list of clients
	initializeClientsCache(&config, client, cache)

	// start polling for clients
	pollClients(&config, client, cache)
}
