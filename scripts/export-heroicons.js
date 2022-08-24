/* eslint-disable no-console */
/* eslint-disable no-restricted-syntax */
/* eslint-disable no-await-in-loop */
/* eslint-disable no-template-curly-in-string */
const path = require('path')
const { copyFile, readdir, mkdir } = require('fs/promises')

const copyDirectory = async (dir, file, type, destinationPath) => {
  const source = path.join(dir, file)

  const destinationDir = path.join(destinationPath, type)
  await mkdir(destinationDir, { recursive: true })

  const destination = path.join(destinationDir, file)
  await copyFile(source, destination)
}

const handle = async () => {
  const types = {
    outline: '24/outline',
    solid: '24/solid',
    mini: '20/solid',
  }
  const destinationPath = path.join(
    __dirname,
    '..',
    'app',
    'assets',
    'svgs',
    'heroicons',
  )
  let copiedIcons = 0

  for (const type of Object.keys(types)) {
    const dirPath = types[type]
    const dir = path.join(__dirname, '..', 'node_modules', 'heroicons', dirPath)
    const files = await readdir(dir)

    for (const file of files) {
      await copyDirectory(dir, file, type, destinationPath)

      copiedIcons++
    }
  }

  return copiedIcons
}

handle().then((count) => console.log(`${count} icons exported`))
