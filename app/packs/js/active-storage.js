document.addEventListener('direct-upload:initialize', (event) => {
  const { target, detail } = event
  const { id, file } = detail

  target.insertAdjacentHTML(
    'beforebegin',
    `
    <div id="direct-upload-${id}" class="direct-upload direct-upload--pending">
      <div id="direct-upload-progress-${id}" class="direct-upload__progress" style="width: 0%"></div>
      <span class="direct-upload__filename"></span>
    </div>
  `,
  )
  target.previousElementSibling.querySelector(
    '.direct-upload__filename',
  ).textContent = file.name
})

document.addEventListener('direct-upload:start', (event) => {
  const { id } = event.detail
  const element = document.getElementById(`direct-upload-${id}`)
  element.classList.remove('direct-upload--pending')
})

document.addEventListener('direct-upload:progress', (event) => {
  const { id, progress } = event.detail
  const progressElement = document.getElementById(
    `direct-upload-progress-${id}`,
  )
  progressElement.style.width = `${progress}%`
})

document.addEventListener('direct-upload:error', (event) => {
  event.preventDefault()
  const { id, error } = event.detail
  const element = document.getElementById(`direct-upload-${id}`)
  element.classList.add('direct-upload--error')
  element.setAttribute('title', error)
})

document.addEventListener('direct-upload:end', (event) => {
  const { id } = event.detail
  const element = document.getElementById(`direct-upload-${id}`)
  element.classList.add('direct-upload--complete')
})
