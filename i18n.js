const german = {
  roads: 'Straßen',
  paths: 'Wege'
}

const reducer = (acc, [key, value]) => {
  acc[german[key]] = value;
  return acc;
}

function translate_keys(hash) {
  return Object.entries(hash).reduce(reducer, {});
}

export { translate_keys };
