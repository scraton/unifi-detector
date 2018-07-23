# Docker

This approach assumes you're comfortable running Alpine Linux as the basis of your app. The build script uses `GOOS=linux` in the `dist` target, so you can swap Alpine out for your weapon of choice.

## Container Files

Aside from copying the compiled application into the container, there's only a single `ADD` instruction in the Docker definition. The `ADD` instruction maps the tree under `container/files` to the container OS root, making static and confd config file management (see below) relatively easy to understand. Much simpler than including a myriad of `ADD` and/or `COPY` instructions in the container definition.

# Managing Configuration Files

Configuration files inside the running container are generated on startup using [confd](https://github.com/kelseyhightower/confd). A slightly more detailed overview of how you can wire your service up to a variety of configuration stores can be found [here](https://github.com/kelseyhightower/confd/blob/master/docs/quick-start-guide.md)

As far as this boilerplate is concerned, template configuration and templates are located under `container/files/etc/confd`. Nothing special to be done with these files other than following confd's documentation. Depending on the backend you decide to use, you might need to modify `container/files/opt/app/start.sh` - it defaults to using environment variables (`backend=env`).

## A Worked Example

In `container/files/etc/confd/conf.d/myapp-config.yml.toml`:

```
[template]
src = "myapp-config.yml.tmpl"
dest = "/opt/app/conf/myapp-config.yml"
```

In `container/files/etc/confd/templates/myapp-config.yml.tmpl`:

```
mysetting: "{{getenv "my_setting"}}"
```

When running the container:

`docker run -d -e my_setting=foo my-container`

If you run the container interactively, you'll find `/opt/app/conf/myapp-config.yml` will be correctly configured as:

```
mysetting: "foo"
```

# Building

This approach makes use of `make`. A quick peek inside `Makefile`, and you'll see two targets of importance:

* `install`: installs the app locally, binaries are dropped to the `bin` folder
* `dist`: builds the app and its Docker container. 

# Running

* You can run the app with logging by using `bin/app` or `docker run app` if you'd like to run the container
* The boilerplate code makes use of [logrus](https://github.com/sirupsen/logrus/)
