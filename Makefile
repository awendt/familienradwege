ROAD_QUERIES=$(addprefix dist/roads/,$(shell ls -1 berlin/roads))
ROAD_XMLS=$(ROAD_QUERIES:.txt=.osm)

MANUAL_QUERIES=$(addprefix dist/manual/,$(shell ls -1 berlin/manual))
MANUAL_XMLS=$(MANUAL_QUERIES:.txt=.osm)

CURL_OPTS = --fail
ifdef VERBOSE
  CURL_OPTS += -v
endif
ifdef USER_AGENT
  CURL_OPTS += --user-agent '$(USER_AGENT)'
endif

build: destination $(ROAD_XMLS) $(MANUAL_XMLS) website/index.html website/roads.json website/manual.json

install: node_modules tools/osmconvert

node_modules:
	npm install osmtogeojson parcel-bundler

destination:
	mkdir -p dist/roads
	mkdir -p dist/manual

dist/roads/%.osm: berlin/roads/%.txt
	curl $(CURL_OPTS) --data @$< http://overpass-api.de/api/interpreter > $@

dist/manual/%.osm: berlin/manual/%.txt
	curl --fail --data @$< http://overpass-api.de/api/interpreter > $@

tools/osmconvert:
	$(MAKE) -C tools

roads.osm: tools/osmconvert $(ROAD_XMLS)
	tools/osmconvert $(ROAD_XMLS) -o=roads.osm

manual.osm: tools/osmconvert $(MANUAL_XMLS)
	tools/osmconvert $(MANUAL_XMLS) -o=manual.osm

website/index.html:
	mkdir -p website
	npx parcel build index.html --out-dir website

website/roads.json: roads.osm
	npx osmtogeojson -m roads.osm > website/roads.json

website/manual.json: manual.osm
	npx osmtogeojson -m manual.osm > website/manual.json
