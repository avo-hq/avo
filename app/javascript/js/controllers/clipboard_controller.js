import Clipboard from '@stimulus-components/clipboard'

export default class extends Clipboard {
  static targets = ['icon', 'iconCopied']

  connect() {
    super.connect()
  }

  copied() {
    this.iconTarget.classList.add('hidden')
    this.iconCopiedTarget.classList.remove('hidden')

    // Reset the icon after a 2 seconds delay
    setTimeout(() => {
      this.iconTarget.classList.remove('hidden')
      this.iconCopiedTarget.classList.add('hidden')
    }, 2000)
  }
}
