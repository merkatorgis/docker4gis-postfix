#!/bin/bash
set -e

[ -z "$POSTFIX_DESTINATION" ] ||
	echo "DESTINATION=$POSTFIX_DESTINATION" >>"$ENV_FILE"

POSTFIX_PORT=$(docker4gis/port.sh "${POSTFIX_PORT:-25}")

mkdir -p "$FILEPORT"
mkdir -p "$RUNNER"

docker container run --restart "$RESTART" --name "$CONTAINER" \
	--env-file "$ENV_FILE" \
	--mount type=bind,source="$FILEPORT",target=/fileport \
	--mount type=bind,source="$FILEPORT/..",target=/fileport/root \
	--mount type=bind,source="$RUNNER",target=/runner \
	--mount source="$VOLUME",target=/volume \
	--network "$NETWORK" \
	--publish "$POSTFIX_PORT":25 \
	--detach "$IMAGE" postfix "$@"
