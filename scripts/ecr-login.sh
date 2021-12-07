#!/usr/bin/env bash
set -eux

ACCOUNT=$(aws sts get-caller-identity | jq -r '.Account')
echo $ACCOUNT
#REGION=???

aws ecr get-login-password | docker login --username AWS --password-stdin "$ACCOUNT.dkr.ecr.us-east-1.amazonaws.com"

