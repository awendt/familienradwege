# Family-friendly bike paths

This project compiles map data from [Open Street Map](https://wiki.openstreetmap.org/wiki/Main_Page) and filters family-friendly bike paths.

## 🧐 What does "family-friendly" mean?

We consider any cycle track to be family-friendly when it's “separated from the road by curbs, parking lots, grass verges, trees or another physical barrier, but is running parallel to and next to the road“ [[src](https://wiki.openstreetmap.org/wiki/Tag:cycleway=track)].

<details>
<summary>This scope was chosen due to Germany's traffic regulations. 🇩🇪</summary>

In short:

1. Kids aged 8 and under **must** ride on the sidewalk
2. Kids between 8 and 10 **may** choose between sidewalk and street
3. Kids aged 10 and old **must** ride on the street
4. Kids of any age **may** ride on separated (protected) bike lanes.
5. Parents **may** accompany their kids on the sidewalk.

As a consequence, the only sane solution for families with kids of mixed ages is to
use separated (protected) bike lanes.

</details>

## 🧩 This is not the whole project

This repository **only deals with map data.**
It will not yield anything nice to look at
– that is, _unless_ you like looking at big JSON files. 🤡

If you're looking for the **website** with the interactive map, check out the
[familienradwege-website](https://github.com/awendt/familienradwege-website) repository.

## 🚀 Getting started

### What you need

This is the software you need installed on your machine:

1. GNU Make
2. Node.js 10.x ([node-osmium](https://github.com/osmcode/node-osmium) provides binaries, it will fall back to source compile and might fail on other versions)
3. `wget` and `curl`
4. [`jq`](https://stedolan.github.io/jq/), the command-line JSON processor

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
   - why geoJSON? Because it's portable (both OpenLayers and Leaflet.js support it)

## What's missing

We're lacking a way of automatically validating the output, e.g. using
[geojson-validation](https://www.npmjs.com/package/geojson-validation)
