sub-init:
	echo "SUB_ID=<input subscription_id>" > sub.env

venv_setup:
	rm -rf .venv
	python3.11 -m venv .venv
	.venv/bin/python -m pip install --upgrade pip
	.venv/bin/python -m pip install -r ./requirements.txt
	# source .tutorial_venv/bin/activate # not possible with Makefile

infra:
	./setup/create_resources.sh
	# Result: variables.env file created
	# May take about 5 min for the key, endpoint to be active

string1="I am an idiot"
string2="You are an idiot"
sample-string:
	.venv/bin/python ./default_moderation.py --text_string $(string1)
	.venv/bin/python ./default_moderation.py --text_string $(string2)

t_file:
	.venv/bin/python ./default_moderation.py --filepath 

i_file:
	.venv/bin/python ./default_moderation.py --imagepath

test_all:
	make t_string t_file i_file


# Commit local branch changes
branch=$(shell git symbolic-ref --short HEAD)
now=$(shell date '+%F_%H:%M:%S' )
git-push:
	git add . && git commit -m "Changes as of $(now)" && git push -u origin $(branch)

git-pull:
	git pull origin $(branch)
