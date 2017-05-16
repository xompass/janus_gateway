# Janus Gateway Docker 

## Build the image 
`docker build -t voxbone-janus .`

## Running & Config

* add `-S stun_srv_addr at` the end of your docker run command to let janus discover its own public ip through stun

* add `-e` if you want to enable event handlers

### TODO

* Clean up unneeded `Utils` packages

