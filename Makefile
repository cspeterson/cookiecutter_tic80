SHELL := /bin/bash
DEPENDENCIES := venv/dependencies.timestamp
STATIC_PYLINT := venv/pylint.timestamp
STATIC_BLACK := venv/black.timestamp
STATIC_MYPY := venv/mypy.timestamp
VENV := venv/venv.timestamp
TITLE := $(shell grep -oP '(?<=# title: ).*' script.py | sed 's/[^a-zA-Z0-9_]/_/g')
VERSION := $(shell grep -oP '(?<=# version: ).*' script.py | sed 's/^ *//g')
BUILD_DIR := dist_$(VERSION)
BUILD := $(BUILD_DIR)/.build.timestamp
_WARN := "\033[33m[%s]\033[0m %s\n"  # Yellow text for "printf"
_TITLE := "\033[32m[%s]\033[0m %s\n" # Green text for "printf"
_ERROR := "\033[31m[%s]\033[0m %s\n" # Red text for "printf"

all: run

$(VENV):
	python3 -m venv venv
	touch $(VENV)
$(DEPENDENCIES): $(VENV) requirements-make.txt
	# Install Python dependencies, runtime *and* test/build
	./venv/bin/python3 -m pip install --requirement requirements-make.txt
	touch $(DEPENDENCIES)

$(STATIC_BLACK): script.py $(DEPENDENCIES)
	# Check style
	@./venv/bin/black --check script.py
	@touch $(STATIC_BLACK)
$(STATIC_MYPY): script.py $(DEPENDENCIES)
	# Check typing
	@./venv/bin/mypy script.py
	@touch $(STATIC_MYPY)
$(STATIC_PYLINT): script.py $(DEPENDENCIES)
	# Lint
	@./venv/bin/pylint script.py
	@touch $(STATIC_PYLINT)
.PHONY: static-analysis
static-analysis: $(DEPENDENCIES) $(STATIC_PYLINT) $(STATIC_MYPY) $(STATIC_BLACK)
	# Hooray all good

.PHONY: hooks
hooks:
	@if $(MAKE) -s confirm-hooks ; then \
	     git config -f .gitconfig core.hooksPath .githooks ; \
	     echo 'git config -f .gitconfig core.hooksPath .githooks'; \
	     git config --local include.path ../.gitconfig ; \
	     echo 'git config --local include.path ../.gitconfig' ; \
	fi

.PHONY: fix
fix: $(DEPENDENCIES)
	# Enforce style in-place with Black
	@black script.py

.PHONY: changelog-verify
changelog-verify: $(DEPENDENCIES)
	# Verify changelog format
	./venv/bin/kacl-cli verify
	# Verify changelog version matches current
	@if [ -z "$$(./venv/bin/kacl-cli current)" ] || [[ $(VERSION) == "$$(./venv/bin/kacl-cli current)" ]]; then true; else false; fi
	#Yay

.PHONY: run
run:
	tic80 --skip --fs=./ --cmd "load cart.py & import code script.py & run" 

.PHONY: build
build: changelog-verify static-analysis $(BUILD)

$(BUILD): 
	# Build the exported program versions
	@for meta in "# title:   game title" "# author:  game developers, email, etc." "# desc:    short description" "# license: MIT License (change this to your license of choice)" "# version: 0.1"; do \
		if grep "^$${meta}$$" script.py; then \
			printf $(_ERROR) ERROR "Fill out metadata in script.py before building"; \
			exit 1; \
		fi; \
	done
	mkdir --parents $(BUILD_DIR)
	@for target in win linux mac html; do \
		echo "Build for target $${target}..."; \
		tic80 --skip --cli --fs=./ --cmd "load cart.py & import code script.py & export $${target} $(BUILD_DIR)/$(TITLE)-$${target} & exit"; \
		echo; \
	done
	touch $(BUILD)


.PHONY: confirm-hooks
confirm-hooks:
	REPLY="" ; \
	printf "⚠ This will configure this repository to use \`core.hooksPath = .githooks\`. You should look at the hooks so you are not surprised by their behavior.\n"; \
	read -p "Are you sure? [y/n] > " -r ; \
	if [[ ! $$REPLY =~ ^[Yy]$$ ]]; then \
		printf $(_ERROR) "KO" "Stopping" ; \
		exit 1 ; \
	else \
		printf $(_TITLE) "OK" "Continuing" ; \
		exit 0; \
	fi \

.PHONY: clean
clean:
	# Cleaning everything but the `venv`
	rm -rf ./dist_*
	rm -rf ./.mypy_cache
	rm -rf ./.pytest_cache
	find . -depth -name '__pycache__' -type d -exec rm -rf {} \;
	find . -name '*.pyc' -a -type f -delete
	# Done

.PHONY: clean-venv
clean-venv:
	rm -rf ./venv
	# Done
