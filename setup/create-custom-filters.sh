#!/bin/bash

#Script to create custom filters
grn=$'\e[1;32m'
end=$'\e[0m'

set -e

# Source information from variables.env
source variables.env
sub_id=$SUB_ID
resourcegroup=$RESOURCE_GROUP
openai_name=$OPENAI_RESOURCE_NAME
custom_filter=$MODIFIED_CUSTOM_FILTER
empty_filter=$EMPTY_CUSTOM_FILTER

az account set -s $sub_id

printf "${grn}Starting to create filters...${end}\n"

printf "${grn}Creating a custom filter...${end}\n"
deployment_result=$(az rest --method PUT \
  --uri "https://management.azure.com/subscriptions/$sub_id/resourceGroups/$resourcegroup/providers/Microsoft.CognitiveServices/accounts/$openai_name/raiPolicies/$custom_filter?api-version=2024-10-01" \
  --body '{
    "properties": {
      "mode": "Default",
      "basePolicyName": "Microsoft.Default",
      "contentFilters": [
        { "name": "Hate",
          "blocking": true,
          "enabled": true,
          "severityThreshold": "Low",
          "source": "Prompt"
        },
        { "name": "Violence",
          "blocking": true,
          "enabled": true,
          "severityThreshold": "Low",
          "source": "Prompt"
        },
        { "name": "Sexual",
          "blocking": true,
          "enabled": true,
          "severityThreshold": "Low",
          "source": "Prompt"
        },
        { "name": "Selfharm",
          "blocking": true,
          "enabled": true,
          "severityThreshold": "Low",
          "source": "Prompt"
        },
        { "name": "Hate",
          "blocking": true,
          "enabled": true,
          "severityThreshold": "Low",
          "source": "Completion"
        },
        { "name": "Violence",
          "blocking": true,
          "enabled": true,
          "severityThreshold": "Low",
          "source": "Completion"
        },
        { "name": "Sexual",
          "blocking": true,
          "enabled": true,
          "severityThreshold": "Low",
          "source": "Completion"
        },
        { "name": "Selfharm",
          "blocking": true,
          "enabled": true,
          "severityThreshold": "Low",
          "source": "Completion"
        }
      ]
    }
  }'
)

printf "${grn}Sleep for 5 seconds...${end}\n"
sleep 5

printf "${grn}Creating an empty custom filter...${end}\n"
deployment_result=$(az rest --method PUT \
  --uri "https://management.azure.com/subscriptions/$sub_id/resourceGroups/$resourcegroup/providers/Microsoft.CognitiveServices/accounts/$openai_name/raiPolicies/$empty_filter?api-version=2024-10-01" \
  --body '{
    "properties": {
      "mode": "Default",
      "basePolicyName": "Microsoft.Default",
      "contentFilters": [
        { "name": "Hate",
          "blocking": false,
          "enabled": false,
          "severityThreshold": "Medium",
          "source": "Prompt"
        },
        { "name": "Violence",
          "blocking": false,
          "enabled": false,
          "severityThreshold": "Medium",
          "source": "Prompt"
        },
        { "name": "Sexual",
          "blocking": false,
          "enabled": false,
          "severityThreshold": "Medium",
          "source": "Prompt"
        },
        { "name": "Selfharm",
          "blocking": false,
          "enabled": false,
          "severityThreshold": "Medium",
          "source": "Prompt"
        },
        { "name": "Hate",
          "blocking": false,
          "enabled": false,
          "severityThreshold": "Medium",
          "source": "Completion"
        },
        { "name": "Violence",
          "blocking": false,
          "enabled": false,
          "severityThreshold": "Medium",
          "source": "Completion"
        },
        { "name": "Sexual",
          "blocking": false,
          "enabled": false,
          "severityThreshold": "Medium",
          "source": "Completion"
        },
        { "name": "Selfharm",
          "blocking": false,
          "enabled": false,
          "severityThreshold": "Medium",
          "source": "Completion"
        }
      ]
    }
  }'
)
