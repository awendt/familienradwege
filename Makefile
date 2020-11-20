CACHE_DIR ?= tmp

.PHONY: verify

ROAD_QUERIES=$(addprefix $(CACHE_DIR)/,$(shell ls -1 berlin/roads))
ROAD_XMLS=$(ROAD_QUERIES:.txt=.osm)

PATH_QUERIES=$(addprefix $(CACHE_DIR)/,$(shell ls -1 berlin/paths))
PATH_XMLS=$(PATH_QUERIES:.txt=.osm)

CURL_OPTS = --fail --retry 5 --no-progress-meter
ifdef VERBOSE
  CURL_OPTS += -v
endif
ifdef USER_AGENT
  CURL_OPTS += --user-agent '$(USER_AGENT)'
endif

build: $(ROAD_XMLS) $(PATH_XMLS) dist/berlin/roads.json dist/berlin/paths.json

ci: build verify

install: node_modules tools/osmconvert tools/osmfilter

all: install build

node_modules:
	npm install

# -------------------------------------------------
# Get map data in OSM format using Overpass queries
# -------------------------------------------------
$(CACHE_DIR)/%.osm: berlin/roads/%.txt
	@mkdir -p $(CACHE_DIR)
	curl $(CURL_OPTS) --data @$< http://overpass-api.de/api/interpreter > $@
	@sleep 1

$(CACHE_DIR)/%.osm: berlin/paths/%.txt
	@mkdir -p $(CACHE_DIR)
	curl $(CURL_OPTS) --data @$< http://overpass-api.de/api/interpreter > $@
	@sleep 1

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
# and remove clutter (in this case, unused nodes)
# --------------------------------------------------
dist/berlin/%.json: %.osm
	@mkdir -p dist/berlin
	npx osmtogeojson -m $< | \
	jq --compact-output '.features |= map(if .geometry.type == "Point" then empty else . end)' > $@

# ------------------
# Verify the results
# ------------------
verify: verify-roads verify-paths

verify-%: dist/berlin/%.json fixtures/%.txt
	@./verify.sh $^
