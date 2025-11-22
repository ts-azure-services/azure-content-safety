#!/bin/bash

#Script to provision a new Azure Content Safety resource...
grn=$'\e[1;32m'
end=$'\e[0m'

set -e

# Start of script
SECONDS=0
printf "${grn}Starting creation of Azure Content Safety.......${end}\n"

# Source subscription ID, and prep config file
source sub.env
sub_id=$SUB_ID

# Set the default subscription 
az account set -s $sub_id

# Source unique name for RG, workspace creation
random_name_generator='/setup/name-generator/random_name.py'
unique_name=$(python3 $PWD$random_name_generator)
number=$[ ( $RANDOM % 10000 ) + 1 ]
resourcegroup=$unique_name$number
resourcetype=$unique_name$number
location='eastus'

# Create a resource group
printf "${grn}Starting creation of resource group...${end}\n"
rg_create=$(az group create --name $resourcegroup --location $location)
printf "Result of resource group create:\n $rg_create \n"

# Create Content Safety Resource
printf "${grn}Starting creation of Azure Content Safety resource...${end}\n"
ws_result=$(az cognitiveservices account create\
  -n $resourcetype \
  -g $resourcegroup \
  -l $location \
  --kind "ContentSafety" \
  --sku 's0'
)
printf "Result of Azure Content Safety resource create:\n $ws_result \n"


# Retrieve endpoint
printf "${grn}Retrieve endpoint...${end}\n"
endpoint=$(az cognitiveservices account show \
-n $resourcetype \
-g $resourcegroup | jq -r .properties.endpoint)
# printf "Result of Azure endpoint retrieval:\n $ws_result \n"


# Retrieve primary key
printf "${grn}Retrieve primary key...${end}\n"
primarykey=$(az cognitiveservices account keys list \
-n $resourcetype \
-g $resourcegroup | jq -r .key1)
# printf "Result of Azure primary key retrieval:\n $ws_result \n"

#
# Create variables file
printf "${grn}Write out env variables file ...${end}\n"
env_variable_file='variables.env'
printf "SUB_ID=$sub_id\n" > $env_variable_file
printf "RESOURCE_GROUP=$resourcegroup\n" >> $env_variable_file
printf "LOCATION=$location\n" >> $env_variable_file
printf "CONTENT_SAFETY_ENDPOINT=$endpoint\n" >> $env_variable_file
printf "CONTENT_SAFETY_KEY=$primarykey\n" >> $env_variable_file
