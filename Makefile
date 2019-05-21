CACHE_DIR ?= tmp
REFRESH ?= 0

ROAD_QUERIES=$(addprefix $(CACHE_DIR)/,$(shell ls -1 berlin/roads))
ROAD_XMLS=$(ROAD_QUERIES:.txt=.osm)

PATH_QUERIES=$(addprefix $(CACHE_DIR)/,$(shell ls -1 berlin/paths))
PATH_XMLS=$(PATH_QUERIES:.txt=.osm)

CURL_OPTS = --fail
ifdef VERBOSE
  CURL_OPTS += -v
endif
ifdef USER_AGENT
  CURL_OPTS += --user-agent '$(USER_AGENT)'
endif

build: destination prepare_cache $(ROAD_XMLS) $(PATH_XMLS) dist/berlin/roads.json dist/berlin/paths.json

install: node_modules tools/osmconvert tools/osmfilter

all: install build

node_modules:
	npm install

destination:
	mkdir -p $(CACHE_DIR)
	mkdir -p dist/berlin

prepare_cache: purge invalidate_random fresh

# -------------------------------------------------
# Remove failed downloads
# -------------------------------------------------
purge:
	find $(CACHE_DIR) -size 0 | xargs rm

# -------------------------------------------------
# Remove random files from the cache
# -------------------------------------------------
invalidate_random:
ifneq (,$(shell ls -1 $(CACHE_DIR)))
ifneq ($(REFRESH),0)
	rm $(shell find $(CACHE_DIR) -type f | sort -R | head -$(REFRESH))
endif
endif

# -------------------------------------------------
# Make sure the cache is perceived as fresh
# -------------------------------------------------
fresh:
ifneq ($(REFRESH),0)
	touch -c $(CACHE_DIR)/*
endif

# -------------------------------------------------
# Get map data in OSM format using Overpass queries
# -------------------------------------------------
$(CACHE_DIR)/%.osm: berlin/roads/%.txt
	curl $(CURL_OPTS) --data @$< http://overpass-api.de/api/interpreter > $@
	sleep 1

$(CACHE_DIR)/%.osm: berlin/paths/%.txt
	curl $(CURL_OPTS) --data @$< http://overpass-api.de/api/interpreter > $@
	sleep 1

# ------------------------------------------------
# Compile required tools:
# - https://wiki.openstreetmap.org/wiki/Osmconvert
# - https://wiki.openstreetmap.org/wiki/Osmfilter
# ------------------------------------------------
tools/osmconvert:
	$(MAKE) -C tools

tools/osmfilter:
	$(MAKE) -C tools

# --------------------------------------------------
# Collect ways shorter than X in a file and describe
# them as deletions.
#
# see https://wiki.openstreetmap.org/wiki/OsmChange
# --------------------------------------------------
dist/tooshort.osc: paths.combined.osm
	./minlength.js paths.combined.osm 10 > dist/tooshort.osc

# ---------------------------------------
# Combine all OSM files into one big file
# ---------------------------------------
roads.combined.osm: tools/osmconvert $(ROAD_XMLS)
	tools/osmconvert $(ROAD_XMLS) -o=roads.combined.osm

paths.combined.osm: tools/osmconvert $(PATH_XMLS)
	tools/osmconvert $(PATH_XMLS) -o=paths.combined.osm

# -----------------------------------------
# Apply osmChange file to remove short ways
# -----------------------------------------
paths.minlength.osm: tools/osmconvert dist/tooshort.osc paths.combined.osm
	tools/osmconvert paths.combined.osm dist/tooshort.osc -o=paths.minlength.osm

# -----------------------------------
# Keep only specific tags in OSM file
# -----------------------------------
roads.osm: tools/osmfilter roads.combined.osm
	tools/osmfilter roads.combined.osm --keep-tags="all bicycle= foot= highway= lit= name= segregated=" -o=roads.osm

paths.osm: tools/osmfilter paths.minlength.osm
	tools/osmfilter paths.minlength.osm --keep-tags="all bicycle= foot= highway= lit= name= segregated=" -o=paths.osm

# --------------------------------------------------
# Finally, convert each OSM file into a geoJSON file
# --------------------------------------------------
dist/berlin/%.json: %.osm
	npx osmtogeojson -m $< > $@
