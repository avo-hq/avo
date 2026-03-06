import PasswordVisibility from '@stimulus-components/password-visibility'

export default class extends PasswordVisibility {
  toggle(event) {
    // Check if the input is disabled before allowing toggle
    if (this.inputTarget.disabled) {
      return
    }

    // Call the parent toggle method if input is not disabled
    super.toggle(event)
  }
}
