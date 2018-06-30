build: dist dist/traberweg.xml

dist:
	mkdir dist

dist/traberweg.xml: berlin/traberweg.osm
	curl --data @berlin/traberweg.osm http://overpass-api.de/api/interpreter > dist/traberweg.xml
