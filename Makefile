# Makefile for a Django app

# Set the default target
.DEFAULT_GOAL := help

# Variables
VENV_NAME := venv
MANAGE_PY := $(VENV_NAME)/bin/python manage.py

# Colors
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m
GREEN := \033[0;32m

# If the first argument is "push"...
ifeq (push,$(firstword $(MAKECMDGOALS)))
  # use the rest as arguments for "push"
  MESSAGE := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  # ...and turn them into do-nothing targets
  $(eval $(MESSAGE):;@:)
endif



# Create a virtual environment
venv:
	@echo "Creating virtual environment..."
	python3 -m venv $(VENV_NAME)
	@echo "$(YELLOW)DONT FORGET TO ACTIVATE VENV AND RUN INSTALL$(NC)"

# Install project dependencies
install:
	@echo "Installing dependencies..."
	$(VENV_NAME)/bin/pip install -r requirements.txt
	$(VENV_NAME)/bin/pip install flake8 pep8-naming flake8-broken-line flake8-return flake8-isort

# Run database migrations
migrate:
	@echo "Running migrations..."
	$(MANAGE_PY) makemigrations
	$(MANAGE_PY) migrate

# Start the development server
run:
	@echo "Starting development server..."
	uvicorn chatgpt.asgi:application --reload

# Run tests
test:
	@echo "Running tests..."
	$(MANAGE_PY) test

# Make new migrations
remigrate:
	@echo "Recreating migrations..."
	$(MANAGE_PY) migrate users zero
	$(MANAGE_PY) migrate news zero
	$(MANAGE_PY) makemigrations
	$(MANAGE_PY) migrate
	@echo "Migrations recreated successfully."

# Loaddata from fixtures
loaddata:
	@echo "Loading data..."
	$(MANAGE_PY) loaddata fixtures/data.json


# Shortcut to createsuperuser
superuser:
	@echo "Creating superuser..."
	$(MANAGE_PY) createsuperuser


# Runs all linter checks
linter:
	@echo "Running linter..."
	isort .
	flake8
	@echo "$(GREEN)All good!$(NC)"


# Runs all linter checks with pushing (secret)
linterfull:
	@echo "Running linter..."
	isort .
	flake8
	@echo "$(GREEN)All good!$(NC)"

	git add --a
	git commit -m 'linter fixes'
	git push


# Run the docker-compose
dc:
	@echo "Creating and running docker-compose configuration..."
	cd infra && docker-compose up --build --remove-orphans

# Clear all docker-compose data
dc_clear:
	@echo "Removing all docker-compose data..."
	docker system prune
	docker volume rm infra_postgres_data


# Pull changes
pull:
	@echo "Pulling changes from origin master..."
	git pull chatgpt main

freeze:
	@echo "Coping all requirements into requirements.txt"
	$(VENV_NAME)/bin/pip freeze > requirements.txt

push:
	@echo "Coping all requirements into requirements.txt"
	git add --all
	git commit -m '$(MESSAGE)'
	git push


help:
	@echo ""
	@echo "Usage: $(YELLOW)make <target>$(NC)"
	@echo ""
	@echo "Available targets:"
	@echo ""
	@echo "$(YELLOW)venv$(NC)             : Create a virtual environment."
	@echo "$(YELLOW)install$(NC)          : Install project dependencies."
	@echo "$(YELLOW)migrate$(NC)          : Run database migrations."
	@echo "$(YELLOW)run$(NC)              : Start the development server."
	@echo "$(YELLOW)test$(NC)             : Run tests."
	@echo "$(YELLOW)remigrate$(NC)        : Make new migrations."
	@echo "$(YELLOW)dc$(NC)               : Run the docker-compose."
	@echo "$(YELLOW)dc_clear$(NC)         : Clear all docker-compose data."
	@echo "$(YELLOW)pull$(NC)             : Pulls changes from main branch."
	@echo "$(YELLOW)linter$(NC)           : Runs linter checks."
	@echo "$(YELLOW)loaddata$(NC)         : Loads data from fixtures."
	@echo ""
