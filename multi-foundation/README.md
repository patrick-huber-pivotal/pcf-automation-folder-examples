# Multi foundation configration

## Overview

This reference shows how to structure a repo for PCF Automation with multiple regions and environments. The sample is generated using pivnet *.pivotal files and the ops manager cli (om).

## Generation

There is a generation script that will create this structure using a generate.yml file. The script has the following dependencies:

### Dependencies

- yq cli : https://github.com/mikefarah/yq
- jq cli : https://stedolan.github.io/jq/
- pivnet cli : https://github.com/pivotal-cf/pivnet-cli
- om cli : https://github.com/pivotal-cf/om

You must have authenticated with the pivnet cli in order to genreate a token in your ~/.pivnetrc file

