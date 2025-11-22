sub-init:
	echo "SUB_ID=<input subscription_id>" > sub.env

infra:
	./setup/create_resources.sh
	# Result: variables.env file created
	# May take about 5 min for the key, endpoint to be active

# venv_setup:
# 	rm -rf .venv
# 	python3.11 -m venv .venv
# 	.venv/bin/python -m pip install --upgrade pip
# 	.venv/bin/python -m pip install -r ./requirements.txt
# 	# source .tutorial_venv/bin/activate # not possible with Makefile

sync-libs:
	uv sync --locked

string1="I am an idiot"
string2="You are an idiot"
sample-string:
	uv run ./default_moderation.py --text_string $(string1)
	uv run ./default_moderation.py --text_string $(string2)

t-file:
	uv run ./default_moderation.py --filepath

i-file:
	uv run ./default_moderation.py --imagepath

test-all:
	make t-file i-file


# Commit local branch changes
branch=$(shell git symbolic-ref --short HEAD)
now=$(shell date '+%F_%H:%M:%S' )

git-push:
	@read -p "Enter commit message: " msg && git add . && git commit -m "$$msg" && git push -u origin $(branch)

git-pull:
	git pull origin $(branch)
