const axios = require('axios')

const ownerAndRepo = process.argv[2]
const [username, repo] = ownerAndRepo.split('/')
const password = process.argv[3]
const url = `https://api.github.com/repos/${username}/${repo}/releases`

async function handle() {
  const {data} = await axios.get(url, {
    headers: {
      'Content-Type': 'application/json'
    },
    auth: {
      username,
      password,
    }
  })

  const draftRelease = data.find((release) => release.name === 'Next release draft')

  if (draftRelease) {
    const deleteUrl = `https://api.github.com/repos/${username}/${repo}/releases/${draftRelease.id}`

    const {data} = await axios.delete(deleteUrl, {
      headers: {
        'Content-Type': 'application/json'
      },
      auth: {
        username,
        password,
      }
    })
  }
}

handle()
