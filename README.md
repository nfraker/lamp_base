# LAMP Base Docker Container

This container has been specifically designed to support Laravel 5 applications. It's tracked publicly on docker.com at
[https://hub.docker.com/r/ikaruwa/lamp_base/](https://hub.docker.com/r/ikaruwa/lamp_base/)

-----
#### Building the LAMP Base Layer

> `docker build -t lamp_base:latest -f lamp_base.docker .`

This will create a foundational container running the following:

 - Ubuntu Linux 16.04 
 - Apache Web Server 2.4
 - MySQL Server 5.7
 - PHP 5.6

By default, the Apache access and error logs will be forwarded to `stdout`, which can then be monitored with the `docker logs` command. An entrypoint command is also generated which will ensure Networking, MySQL, and Apache services are ran on startup.

Note that termination of the Apache service will result in the container being stopped by the Docker engine, however `service apache2 reload` can still be used to allow for a graceful reload of Apache configuration files.
