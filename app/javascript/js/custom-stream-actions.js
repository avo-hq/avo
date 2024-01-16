/* eslint-disable camelcase */
import { StreamActions } from '@hotwired/turbo'
import { saveAs } from 'file-saver'

StreamActions.download = () => {
  saveAs(
    new Blob(
      [this.getAttribute('content')],
    ),
    this.getAttribute('filename'),
  )
}
