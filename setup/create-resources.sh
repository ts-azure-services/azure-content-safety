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
rg_create=$(az group create --name $resourcegroup --location $location --tags marker=delete)
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


# # Create Azure OpenAI Resource
# openai_name="${unique_name}openai${number}"
# printf "${grn}Starting creation of Azure OpenAI resource...${end}\n"
# openai_result=$(az cognitiveservices account create \
#   -n $openai_name \
#   -g $resourcegroup \
#   -l $location \
#   --kind "OpenAI" \
#   --sku "S0" \
#   --yes)
# printf "Result of Azure OpenAI resource create:\n $openai_result \n"
#
# printf "${grn}Sleep for 5 seconds...${end}\n"
# sleep 5

# Create Azure OpenAI Foundry Resource
openai_name="${unique_name}openai${number}"
printf "${grn}Starting creation of Azure OpenAI Foundry resource...${end}\n"
openai_result=$(az cognitiveservices account create \
  -n $openai_name \
  -g $resourcegroup \
  -l $location \
  --kind "AIServices" \
  --sku "S0" \
  --yes)
printf "Result of Azure OpenAI resource create:\n $openai_result \n"

printf "${grn}Sleep for 5 seconds...${end}\n"
sleep 5

# Deploy gpt-4o-mini model (global standard)
deployment_name="gpt-4o-mini"
model_name="gpt-4o-mini"
model_version="2024-07-18"
printf "${grn}Deploying gpt-4o-mini model...${end}\n"
deployment_result=$(az cognitiveservices account deployment create \
  --resource-group $resourcegroup \
  --name $openai_name \
  --deployment-name $deployment_name \
  --model-name $model_name \
  --model-version $model_version \
  --model-format OpenAI \
  --sku "Standard" \
  --sku-capacity 100
)
printf "Result of gpt-4o-mini deployment:\n $deployment_result \n"

# Retrieve OpenAI endpoint
openai_endpoint=$(az cognitiveservices account show \
  -n $openai_name \
  -g $resourcegroup | jq -r .properties.endpoint)

# Retrieve OpenAI API key
printf "${grn}Retrieve OpenAI API key...${end}\n"
openai_key=$(az cognitiveservices account keys list \
  -n $openai_name \
  -g $resourcegroup | jq -r .key1)

# Create variables file
printf "${grn}Write out env variables file ...${end}\n"
env_variable_file='variables.env'
printf "#High level\n" > $env_variable_file
printf "SUB_ID=$sub_id\n" >> $env_variable_file
printf "RESOURCE_GROUP=$resourcegroup\n" >> $env_variable_file
printf "LOCATION=$location\n" >> $env_variable_file
printf "\n" >> $env_variable_file
printf "#Content safety details\n" >> $env_variable_file
printf "CONTENT_SAFETY_ENDPOINT=$endpoint\n" >> $env_variable_file
printf "CONTENT_SAFETY_KEY=$primarykey\n" >> $env_variable_file
printf "\n" >> $env_variable_file
printf "#OpenAI details\n" >> $env_variable_file
printf "OPENAI_RESOURCE_NAME=$openai_name\n" >> $env_variable_file
printf "OPENAI_ENDPOINT=$openai_endpoint\n" >> $env_variable_file
printf "OPENAI_KEY=$openai_key\n" >> $env_variable_file
printf "OPENAI_DEPLOYMENT_NAME=$deployment_name\n" >> $env_variable_file
printf "EMPTY_CUSTOM_FILTER=empty-custom\n" >> $env_variable_file
printf "MODIFIED_CUSTOM_FILTER=modified-custom\n" >> $env_variable_file
