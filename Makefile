##@ Create infrastructure
sub-init: ## Create sub env file
	echo "SUB_ID=<input subscription_id>" > sub.env

infra: ## Create resources
	./setup/create-resources.sh
	# Result: variables.env file created
	# May take about 5 min for the key, endpoint to be active
	make create-custom-filters
	make attach-custom-filter

create-custom-filters: ## Create custom filters (empty & modified)
	./setup/create-custom-filters.sh

attach-custom-filter: ## Attach custom filter to deployment
	./setup/attach-filter-to-deployment.sh


subscription_id=$(shell cat sub.env | grep "SUB_ID" | cut -d "=" -f 2 | xargs)
delete-resources: ## Delete resource groups with marker=delete
	@az group list --subscription "$(subscription_id)" --tag marker=delete --query "[].name" -o tsv | xargs -n1 -t -I {} az group delete --subscription "$(subscription_id)" --no-wait --yes -n "{}"

sync-libs: ## Sync uv dependencies
	uv sync --locked

##@ Basic content safety operations
string1="I am an idiot"
string2="You are an idiot"
sample-string:
	uv run ./default_moderation.py --text_string $(string1)
	uv run ./default_moderation.py --text_string $(string2)

t-file:
	uv run ./default_moderation.py --filepath

i-file:
	uv run ./default_moderation.py --imagepath

test-all: ## Test all content safety operations
	make sample-string t-file i-file

##@ SDK calls
# message="You stupid idiot!"
message="Fucking hate them!!!"
basic-sdk: ## Basic usage with a message
	uv run ./sdk_calls.py --message $(message)

custom-sdk: ## Message, with empty filter
	uv run ./sdk_calls.py --message $(message) --use-custom-policy

##@ Github operations
branch=$(shell git symbolic-ref --short HEAD)
now=$(shell date '+%F_%H:%M:%S' )

git-push: ## Git push
	@read -p "Enter commit message: " msg && git add . && git commit -m "$$msg" && git push -u origin $(branch)

git-pull: ## Git pull
	git pull origin $(branch)

##@ Help
help: ## Show this help message (grouped by sections)
	@awk 'BEGIN {FS = ":.*?## "} \
		/^##@/ {printf "\n\033[1;35m%s\033[0m\n", substr($$0, 5)} \
		/^[a-zA-Z0-9_.-]+:.*?## / {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}' \
		$(MAKEFILE_LIST)
