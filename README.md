# Family-friendly bike paths

[![Greenkeeper badge](https://badges.greenkeeper.io/awendt/familienradwege.svg)](https://greenkeeper.io/)

This project compiles map data from [Open Street Map](https://wiki.openstreetmap.org/wiki/DE:Hauptseite) and filters family-friendly bike paths.

## Getting started

### Prerequisites

This is the software you need:

1. GNU Make
2. Node.js 10.x ([node-osmium](https://github.com/osmcode/node-osmium) provides binaries, it will fall back to source compile and might fail on other versions)
3. `wget`

### Building the project

Once you have installed all required software,
in the root directory of this project, run:

```
make all
```

This will do the following:

1. **Install project dependencies**
   - JS dependencies are installed via `npm` into `node_modules`
   - tools are compiled from source into `tools`
2. **Download map data**
   - query the [Overpass API](https://wiki.openstreetmap.org/wiki/Overpass_API)
   in small batches
   - download pieces of map data in
   [OSM format](https://wiki.openstreetmap.org/wiki/OSM_XML)
   - combine the pieces into a large file
3. **Reduce data size**
   - [filter](https://wiki.openstreetmap.org/wiki/Osmfilter) the data by
   [keeping only specific parts](https://wiki.openstreetmap.org/wiki/Osmfilter#Tags_Filter)
   - find ways that are too short, [generate a diff of them](minlength.js)
   and apply that diff (see [osmChange](https://wiki.openstreetmap.org/wiki/OsmChange))
4. **Convert data into geoJSON format**
   - done by [osmtogeojson](https://github.com/tyrasd/osmtogeojson)
   - why geoJSON? Because it's
     [supported by Leaflet.js](https://leafletjs.com/examples/geojson/) out-of-the-box

Our [website](https://github.com/awendt/familienradwege-website) then shows that data
on an interactive map.

### What's missing

We're lacking a way of automatically validating the output, e.g. using
[geojson-validation](https://www.npmjs.com/package/geojson-validation)
