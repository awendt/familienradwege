const BERLIN_COORDINATES = [52.480, 13.454];

const geojson_options = {
  pointToLayer: () => {}
}

export const map = L.map('mapid').setView(BERLIN_COORDINATES, 12);

export const layers = {
  roads: new L.geoJSON(undefined, geojson_options),
  manual: new L.geoJSON(undefined, geojson_options)
};
