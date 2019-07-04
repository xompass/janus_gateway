# Janus Gateway Docker
Optimized for using it as a Live Streaming Server

## Build the image 

`docker build -t streaming-janus .`

## Running & Config with docker

* add `-S stun_srv_addr at` the end of your docker run command to let janus discover its own public ip through stun

* add `-e` if you want to enable event handlers

## Running & Config with docker docker-compose

`docker-compose up`

### TODO

* Clean up unneeded `Utils` packages

