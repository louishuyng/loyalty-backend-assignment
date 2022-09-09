#!/bin/bash

DOCKER_PATH=docker-compose.prod.yaml

docker-compose -f $DOCKER_PATH down &&\
	docker-compose -f $DOCKER_PATH build &&\
	docker-compose -f $DOCKER_PATH up -d
