venv_setup:
	#conda create -n content-safety python=3.10 -y; conda activate content-safety
	pip install azure-ai-contentsafety
	pip install python-dotenv
	pip install flake8

initialize:
	echo "SUB_ID=subscription_id" > sub.env

create:
	./setup/create_resources.sh
	# Result: variables.env file created

t_string:
	python ./test_feature.py --text_string "I am an idiot"
	python ./test_feature.py --text_string "You are an idiot"

t_file:
	python ./test_feature.py --filepath 

i_file:
	python ./test_feature.py --imagepath

test_all:
	make t_string t_file i_file
