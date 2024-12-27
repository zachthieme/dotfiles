const url = 'http://10.0.0.45:9123/elgato/lights'

const json = await (await fetch(url)).json()

const light = json.lights[0]

light.on ^= 1

const changed = await fetch(url, {
  method: 'PUT',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify(json)
  
})