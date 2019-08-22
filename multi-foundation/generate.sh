#!/bin/bash

# get script directory and sets the root of the container
export DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
export ROOT=$DIR

# clenup the root directories
rm -rf $DIR/config
mkdir -p $DIR/config

# clieanup the region specific folders
yq r -j generate.yml regions[*].name | jq .[] -r | xargs rm -rf $1

# grab the pivnet token
export PIVNET_TOKEN=$(yq r -j ~/.pivnetrc | jq -r .profiles[0].api_token)

# generate each product configuration
yq r -j generate.yml | jq -r '.products[] | "om config-template --output-directory $DIR/config --pivnet-api-token $PIVNET_TOKEN --pivnet-product-slug \(.slug | @sh) --product-version \(.version | @sh) --product-file-glob \(.glob | @sh)"' | while IFS= read -r line; do eval "$line"; done

rm -rf $DIR/config/*/*/features
rm -rf $DIR/config/*/*/network
rm -rf $DIR/config/*/*/optional
rm -rf $DIR/config/*/*/resource

for REGION in $(yq r -j generate.yml | jq .regions[].name -r) 
do
    for ENVIRONMENT in $(yq r -j generate.yml | jq -r --arg REGION $REGION '.regions[] | select(.name == $REGION ) | .environments[].name' | grep -v -e '^$')
    do
      mkdir -p $DIR/$REGION/$ENVIRONMENT
      cp -r $DIR/config/* $DIR/$REGION/$ENVIRONMENT/
      find $DIR/$REGION/$ENVIRONMENT -type f ! -iname "*-vars*.yml" -delete
    done
done

# if only using local variables, uncomment
# find $DIR/config -type f -iname "*-vars*.yml" -delete
