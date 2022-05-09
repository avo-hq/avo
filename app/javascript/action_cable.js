import { createConsumer } from '@rails/actioncable'

// eslint-disable-next-line import/no-mutable-exports
let consumer

if (window.Avo.configuration.action_cable.enabled) {
  consumer = createConsumer()

  window.Avo.consumer = consumer
}

export default consumer
