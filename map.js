const BERLIN_COORDINATES = [52.480, 13.454];

const GEOJSON_OPTIONS = {
  pointToLayer: () => {}
}

export const map = L.map('mapid').setView(BERLIN_COORDINATES, 12);

export const layers = {
  roads: new L.geoJSON(undefined, GEOJSON_OPTIONS),
  manual: new L.geoJSON(undefined, GEOJSON_OPTIONS)
};
