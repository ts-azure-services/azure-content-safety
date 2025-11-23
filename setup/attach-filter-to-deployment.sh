#!/bin/bash

# Script to attach custom filter to deployment
grn=$'\e[1;32m'
end=$'\e[0m'

set -e

# Source information from variables.env
source variables.env
sub_id=$SUB_ID
resourcegroup=$RESOURCE_GROUP
openai_name=$OPENAI_RESOURCE_NAME
deployment_name=$OPENAI_DEPLOYMENT_NAME
custom_filter=$MODIFIED_CUSTOM_FILTER
model_name="gpt-4o-mini"
model_version="2024-07-18"

az account set -s $sub_id

printf "${grn}Attaching the custom filter to the new deployment...${end}\n"
deployment_result=$(az rest --method PUT \
  --uri "https://management.azure.com/subscriptions/$sub_id/resourceGroups/$resourcegroup/providers/Microsoft.CognitiveServices/accounts/$openai_name/deployments/$deployment_name?api-version=2023-10-01-preview" \
  --body '{
    "sku": {
      "name": "Standard",
      "capacity": 1
    },
    "properties": {
      "model": {
        "format": "OpenAI",
        "name": "'"$model_name"'",
        "version": "'"$model_version"'"
      },
      "raiPolicyName": "'"$custom_filter"'"
    }
  }'
)
printf "${grn}Attachment of custom filter to deployment complete!${end}\n"
