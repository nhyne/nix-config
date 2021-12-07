#!/usr/bin/env bash
set -eu

ACCOUNT=$(aws sts get-caller-identity | jq -r '.Account')
#REGION=???

aws ecr get-login-password | docker login --username AWS --password-stdin "$ACCOUNT.dkr.ecr.us-east-1.amazonaws.com"

