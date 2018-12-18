ROAD_QUERIES=$(addprefix dist/roads/,$(shell ls -1 berlin/roads))
ROAD_XMLS=$(ROAD_QUERIES:.txt=.osm)

PATH_QUERIES=$(addprefix dist/paths/,$(shell ls -1 berlin/paths))
PATH_XMLS=$(PATH_QUERIES:.txt=.osm)

CURL_OPTS = --fail
ifdef VERBOSE
  CURL_OPTS += -v
endif
ifdef USER_AGENT
  CURL_OPTS += --user-agent '$(USER_AGENT)'
endif

build: destination $(ROAD_XMLS) $(PATH_XMLS) dist/berlin/roads.json dist/berlin/paths.json

install: node_modules tools/osmconvert tools/osmfilter

node_modules:
	npm install osmtogeojson parcel-bundler

destination:
	mkdir -p dist/paths
	mkdir -p dist/roads
	mkdir -p dist/berlin

dist/roads/%.osm: berlin/roads/%.txt
	curl $(CURL_OPTS) --data @$< http://overpass-api.de/api/interpreter > $@

dist/paths/%.osm: berlin/paths/%.txt
	curl $(CURL_OPTS) --fail --data @$< http://overpass-api.de/api/interpreter > $@

tools/osmconvert:
	$(MAKE) -C tools

tools/osmfilter:
	$(MAKE) -C tools

dist/tooshort.osc: paths.combined.osm
	./minlength.js paths.combined.osm 10 > dist/tooshort.osc

roads.combined.osm: tools/osmconvert $(ROAD_XMLS)
	tools/osmconvert $(ROAD_XMLS) -o=roads.combined.osm

roads.osm: tools/osmfilter roads.combined.osm
	tools/osmfilter roads.combined.osm --keep-tags="all bicycle= foot= highway= lit= name= segregated=" -o=roads.osm

paths.combined.osm: tools/osmconvert $(PATH_XMLS)
	tools/osmconvert $(PATH_XMLS) -o=paths.combined.osm

paths.minlength.osm: tools/osmconvert dist/tooshort.osc paths.combined.osm
	tools/osmconvert paths.combined.osm dist/tooshort.osc -o=paths.minlength.osm

paths.osm: tools/osmfilter paths.minlength.osm
	tools/osmfilter paths.minlength.osm --keep-tags="all bicycle= foot= highway= lit= name= segregated=" -o=paths.osm

dist/berlin/%.json: %.osm
	npx osmtogeojson -m $< > $@
