DOCKER_REPO = phpmyadmin

.PHONY: all build run logs clean stop rm prune

all: build run logs

build: build-apache build-fpm build-fpm-alpine

build-apache:
	docker build ${DOCKER_FLAGS} -t ${DOCKER_REPO}:testing apache

build-fpm:
	docker build ${DOCKER_FLAGS} -t ${DOCKER_REPO}:testing-fpm fpm

build-fpm-alpine:
	docker build ${DOCKER_FLAGS} -t ${DOCKER_REPO}:testing-fpm-alpine fpm-alpine

run:
	docker-compose -f ./testing/docker-compose/docker-compose.testing-default.yml up -d

testing-%:
	docker-compose -f ./testing/docker-compose/docker-compose.$@.yml up --build --abort-on-container-exit --exit-code-from=sut
	docker-compose -f ./testing/docker-compose/docker-compose.$@.yml down

run-tests: testing-default testing-one-host testing-different-apache-port

logs:
	docker-compose -f ./testing/docker-compose/docker-compose.testing-default.yml logs

clean: stop rm prune

stop:
	docker-compose -f ./testing/docker-compose/docker-compose.testing-default.yml stop

rm:
	docker-compose -f ./testing/docker-compose/docker-compose.testing-default.yml rm

prune:
	docker rm `docker ps -q -a --filter status=exited`
	docker rmi `docker images -q --filter "dangling=true"`
