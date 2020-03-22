# docker-moodle-unprivileged

A Dockerfile that installs and runs the latest Moodle 3.8 stable, with external MySQL Database.

Ghostscript and unoconv are included in this image.

It is configured to run unprivileged, e. g. in Kubernetes with the setting MustRunAsNonRoot in the pod security policies.

Note: DB Deployment uses version 5 of MySQL. MySQL:Latest is now v8.

## Building

```
git clone https://github.com/qnipp/docker-moodle-unprivileged
cd docker-moodle-unprivileged
docker build -t moodle-unprivileged .
```

## Usage

To spawn a new instance of Moodle:

```
docker run -d -p 3306:3306 -e MYSQL_DATABASE=moodle -e MYSQL_ROOT_PASSWORD=moodle -e MYSQL_USER=moodle -e MYSQL_PASSWORD=secret mysql:5
docker run --net=host -vmoodle-data:/var/moodledata qnipp/moodle-unprivileged
```

You can visit the following URL in a browser to get started:

```
http://localhost:8080 
```

## Production Deployment

The image is built to run with the runAsNonRoot security setting in a k8s environment.

A cron job must be set up, which calls http://moodle/admin/cron.php every minute. This can be done by using the curlimages/curl image. Calling the cron job this way must be enabled. It is recommended to set up a password, see https://docs.moodle.org/38/en/Cron#The_web_based_Moodle_cron_command for details.

## Configuration

Variable | Description | Default
---------|-------------|--------
MOODLE_URL | Sets the URL of the Moodle installation | http://127.0.0.1:8080
DB_TYPE | Database type | mysqli
DB_HOST | Database host | 127.0.0.1
DB_PORT | Database port | 3306
DB_NAME | Database name | moodle
DB_USER | Database user | moodle
DB_PASSWORD | Database password | secret
SSL_PROXY | Set to true, if the installation is behind a SSL proxy | false

## Logs

The Apache access and error logs are written on stdout.

## E-Mail

Acess to an SMTP service (with SSL/TLS and authentication) can be configured in the Moodle application itself. See https://docs.moodle.org/38/en/Installing_Moodle#Final_configuration for this and other tasks to be performed within Moodle.

## Credits

This is a fork of [Jonathan Hardison's](https://github.com/jmhardison/docker-moodle) Dockerfile,
which is a fork of [Jade Auer's](https://github.com/jda/docker-moodle) Dockerfile.
This is a reductionist take on [sergiogomez](https://github.com/sergiogomez/)'s docker-moodle Dockerfile.
