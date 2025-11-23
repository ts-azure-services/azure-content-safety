# azure-content-safety
A repo for Azure Content Safety resources.

## Goals
- Show basic Content Safety operations.
- With an Azure OpenAI deployment:
- Show the use of a custom filter on both chat completions & responses API.
- Show the use of bypassing with an empty filter using the `x-policy-id` header to a custom "empty" filter.

## Observation
- REST API Low = GUI High, and vice versa. Flagged with PG.
- When you create this with an Azure OpenAI resource vs. an Azure AI Foundry resource, the responses seem a little inconsistent and unstable (for content filtering) with the former, especially with the Responses API.
