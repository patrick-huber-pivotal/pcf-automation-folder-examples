#!/bin/bash

# get script directory and sets the root of the container
export DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
export ROOT=$DIR

# clenup the root directories
rm -rf $DIR/config

# clieanup the region specific folders
yq r -j generate.yml regions[*].name | jq .[] -r | xargs rm -rf $1

# grab the pivnet token
export PIVNET_TOKEN=$(yq r -j ~/.pivnetrc | jq -r .profiles[0].api_token)

for REGION in $(yq r -j generate.yml | jq .regions[].name -r) 
do
    for ENVIRONMENT in $(yq r -j generate.yml | jq -r --arg REGION $REGION '.regions[] | select(.name == $REGION ) | .environments[].name' | grep -v -e '^$')
    do
      mkdir -p $DIR/$REGION/$ENVIRONMENT
      yq r -j generate.yml | jq -r '.products[] | "om config-template --output-directory $DIR/$REGION/$ENVIRONMENT --pivnet-api-token $PIVNET_TOKEN --pivnet-product-slug \(.slug | @sh) --product-version \(.version | @sh) --product-file-glob \(.glob | @sh)"' | while IFS= read -r line; do eval "$line"; done
    done
done
