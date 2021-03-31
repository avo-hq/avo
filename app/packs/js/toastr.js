import toastr from 'toastr/build/toastr.min'

toastr.options.showDuration = 400
toastr.options.hideDuration = 400
toastr.options.closeButton = true
toastr.options.positionClass = 'toast-bottom-right'
// eslint-disable-next-line max-len
toastr.options.closeHtml = '<button class="mt-2 mr-1"><svg class="w-4 h-4 text-gray-700" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" /></svg></button>'

window.toastr = toastr
