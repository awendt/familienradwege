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

# always re-build website
.PHONY: website/index.html

build: destination $(ROAD_XMLS) $(PATH_XMLS) website/index.html website/roads.json website/paths.json

install: node_modules tools/osmconvert

node_modules:
	npm install osmtogeojson parcel-bundler

destination:
	mkdir -p dist/paths
	mkdir -p dist/roads

dist/roads/%.osm: berlin/roads/%.txt
	curl $(CURL_OPTS) --data @$< http://overpass-api.de/api/interpreter > $@

dist/paths/%.osm: berlin/paths/%.txt
	curl --fail --data @$< http://overpass-api.de/api/interpreter > $@

tools/osmconvert:
	$(MAKE) -C tools

roads.osm: tools/osmconvert $(ROAD_XMLS)
	tools/osmconvert $(ROAD_XMLS) -o=roads.osm

paths.osm: tools/osmconvert $(PATH_XMLS)
	tools/osmconvert $(PATH_XMLS) -o=paths-all.osm
	./minlength.js paths-all.osm 10 > dist/tooshort.osc
	tools/osmconvert paths-all.osm dist/tooshort.osc -o=paths-unclean.osm
	tools/osmfilter paths-unclean.osm --keep-tags="all bicycle= foot= highway= lit= name= segregated=" -o=paths.osm

website/index.html:
	mkdir -p website
	npx parcel build index.html --out-dir website

website/%.json: %.osm
	npx osmtogeojson -m $< > $@
