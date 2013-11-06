TOP_DIR_WITH_SLASH := $(dir $(lastword $(MAKEFILE_LIST)))
TOP_DIR := $(TOP_DIR_WITH_SLASH:/=)

SRC_DIR := $(TOP_DIR)/src
MOD_DIR := $(TOP_DIR)/node_modules
BLD_DIR := $(TOP_DIR)/_build

JADE_BIN := $(MOD_DIR)/jade/bin/jade
STYLUS_BIN := $(MOD_DIR)/stylus/bin/stylus
COFFEE_BIN := $(MOD_DIR)/coffee-script/bin/coffee
UGLIFY_BIN := $(MOD_DIR)/uglify-js/bin/uglifyjs
HTTP_BIN := $(MOD_DIR)/http-server/bin/http-server

BUILD_BINS := $(JADE_BIN) $(STYLUS_BIN) $(COFFEE_BIN) $(UGLIFY_BIN)

PORT ?= 8000

DIR := $(BLD_DIR)
PUB_DIR = $(DIR)/public

mode ?= development
MODE ?= $(mode)
ifeq ($(MODE), release)
DIR := $(TOP_DIR)
endif

.PHONY: install build foo clean clean-build %.release .ASSETS

# ---

install:
	@echo "Installing using NPM:"
	@npm install

build: \
	.ASSETS \
	$(PUB_DIR)/bm-w.js \
	$(PUB_DIR)/bm-w.css \
	$(DIR)/index.html

run:
	@$(HTTP_BIN) $(DIR)/ -p $(PORT)

release: build
	rm -rf $(TOP_DIR)/index.html $(TOP_DIR)/public
	git checkout master
	cp -r $(BLD_DIR)/* $(TOP_DIR)/ && rm -r $(BLD_DIR)
	@git add -u
	@git status

# ---

$(DIR)/:
	mkdir -p $(DIR)

$(PUB_DIR)/: $(DIR)
	mkdir -p $(PUB_DIR)/lib
	curl -s http://cdnjs.cloudflare.com/ajax/libs/meyer-reset/2.0/reset.min.css -o $(PUB_DIR)/lib/reset.css
	curl -s http://ajax.googleapis.com/ajax/libs/angularjs/1.2.0-rc.2/angular.min.js -o $(PUB_DIR)/lib/angular.js
	curl -s http://d3js.org/d3.v3.min.js -o $(PUB_DIR)/lib/d3.js

# ---

$(DIR)/index.html: $(SRC_DIR)/index.jade $(BUILD_BINS) $(DIR)
	$(JADE_BIN) < $(SRC_DIR)/index.jade > $(DIR)/index.html

$(PUB_DIR)/bm-w.css: $(SRC_DIR)/base.styl $(BUILD_BINS) $(PUB_DIR)
	$(STYLUS_BIN) < $(SRC_DIR)/base.styl > $(PUB_DIR)/bm-w.css

NG_SCRIPTS := \
	$(SRC_DIR)/controllers.coffee \
	$(SRC_DIR)/directives.coffee
$(PUB_DIR)/bm-w.js: $(NG_SCRIPTS) $(BUILD_BINS) $(PUB_DIR)
	$(COFFEE_BIN) -cbj /dev/null -p $(NG_SCRIPTS) | $(UGLIFY_BIN) - -m toplevel=true -c > $(PUB_DIR)/bm-w.js

.ASSETS:
	cp $(TOP_DIR)/assets/* $(PUB_DIR)/

# ---

clean:
	rm -rf $(MOD_DIR) $(BLD_DIR)
