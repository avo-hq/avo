const axios = require('axios')

const url = `https://avohq.io/releases/refresh_releases`

async function handle() {
  await axios.get(url)
}

handle()
