#!/bin/bash
# AUTHOR: RyoNak

set -e

# Variable
FILE=$1

# Functions
gpg_decode() {
    gpg -dq $FILE
}

# Extract config
if [[ "${FILE: -4}" == ".gpg" ]]; then
    WOLFRAM_ID=$(gpg_decode |jq -r '.WOLFRAM_ID');
    WOLFRAM_PASSWORD=$(gpg_decode |jq -r '.WOLFRAM_PASSWORD');
else
    WOLFRAM_ID=$(jq -r '.WOLFRAM_ID' $FILE);
    WOLFRAM_PASSWORD=$(jq -r '.WOLFRAM_PASSWORD' $FILE);
fi


# Docker Build
docker buildx build . \
    --file Dockerfile \
    --build-arg BASE_IMAGE=wolframresearch/wolframengine \
    --build-arg WOLFRAM_ID=$WOLFRAM_ID \
    --build-arg WOLFRAM_PASSWORD=$WOLFRAM_PASSWORD \
    --tag ryonak/wolfram-jupyterserver:latest
