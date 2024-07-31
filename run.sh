#!/bin/bash
set -e

IMAGE=$IMAGE
CONTAINER=$CONTAINER
DOCKER_ENV=$DOCKER_ENV
RESTART=$RESTART
NETWORK=$NETWORK
FILEPORT=$FILEPORT
RUNNER=$RUNNER
VOLUME=$VOLUME

POSTFIX_DESTINATION=$POSTFIX_DESTINATION

POSTFIX_PORT=$(docker4gis/port.sh "${POSTFIX_PORT:-25}")

mkdir -p "$FILEPORT"
mkdir -p "$RUNNER"

docker container run --restart "$RESTART" --name "$CONTAINER" \
	-e DOCKER_ENV="$DOCKER_ENV" \
	--mount type=bind,source="$FILEPORT",target=/fileport \
	--mount type=bind,source="$FILEPORT/..",target=/fileport/root \
	--mount type=bind,source="$RUNNER",target=/runner \
	--mount source="$VOLUME",target=/volume \
	--network "$NETWORK" \
	-e "$(docker4gis/noop.sh DESTINATION "$POSTFIX_DESTINATION")" \
	-p "$POSTFIX_PORT":25 \
	-d "$IMAGE" postfix "$@"
