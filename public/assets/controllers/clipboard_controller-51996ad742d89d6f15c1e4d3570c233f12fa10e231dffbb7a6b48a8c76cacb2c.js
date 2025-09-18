import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { text: String }

  // Copy text to clipboard
  copy(event) {
    event.preventDefault()

    const textToCopy = this.textValue || event.target.dataset.clipboardText

    if (textToCopy) {
      navigator.clipboard.writeText(textToCopy).then(() => {
        // Update button text temporarily
        this.updateButtonState(event.target)

        // Show success toast
        this.showToast('Code copié dans le presse-papier !', 'success')
      }).catch(err => {
        // Fallback for older browsers
        this.fallbackCopy(textToCopy)
        this.updateButtonState(event.target)
        this.showToast('Code copié !', 'success')
      })
    }
  }

  // Fallback copy method for older browsers
  fallbackCopy(text) {
    const textArea = document.createElement('textarea')
    textArea.value = text
    textArea.style.position = 'fixed'
    textArea.style.left = '-999999px'
    textArea.style.top = '-999999px'
    document.body.appendChild(textArea)
    textArea.focus()
    textArea.select()

    try {
      document.execCommand('copy')
    } catch (err) {
      console.error('Fallback copy failed:', err)
    }

    document.body.removeChild(textArea)
  }

  // Update button state after copy
  updateButtonState(button) {
    const originalText = button.innerHTML
    const allButtons = document.querySelectorAll('.copy-btn')

    // Reset all buttons
    allButtons.forEach(btn => {
      btn.classList.remove('bg-green-600')
      btn.classList.add('bg-gray-600')
      const iconPath = btn.querySelector('svg path')
      if (iconPath) {
        iconPath.setAttribute('d', 'M8 3a1 1 0 011-1h6a1 1 0 011 1v3a1 1 0 11-2 0V4H9v10h1a1 1 0 110 2H8a1 1 0 01-1-1V3z M6 5a1 1 0 011-1h6a1 1 0 011 1v1a1 1 0 11-2 0V6H8v8h1a1 1 0 110 2H7a1 1 0 01-1-1V5z')
      }
    })

    // Update clicked button
    button.classList.remove('bg-gray-600')
    button.classList.add('bg-green-600')

    const iconPath = button.querySelector('svg path')
    if (iconPath) {
      iconPath.setAttribute('d', 'M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z')
    }

    // Reset after 2 seconds
    setTimeout(() => {
      button.classList.remove('bg-green-600')
      button.classList.add('bg-gray-600')
      if (iconPath) {
        iconPath.setAttribute('d', 'M8 3a1 1 0 011-1h6a1 1 0 011 1v3a1 1 0 11-2 0V4H9v10h1a1 1 0 110 2H8a1 1 0 01-1-1V3z M6 5a1 1 0 011-1h6a1 1 0 011 1v1a1 1 0 11-2 0V6H8v8h1a1 1 0 110 2H7a1 1 0 01-1-1V5z')
      }
    }, 2000)
  }

  // Show toast notification
  showToast(message, type = 'success') {
    // Remove existing toasts
    const existingToasts = document.querySelectorAll('.toast-notification')
    existingToasts.forEach(toast => toast.remove())

    const toast = document.createElement('div')
    toast.className = `toast-notification fixed top-4 right-4 px-6 py-3 rounded-lg shadow-lg text-white font-medium z-50 transform transition-all duration-300 translate-x-full opacity-0`

    if (type === 'success') {
      toast.classList.add('bg-green-600')
    } else if (type === 'error') {
      toast.classList.add('bg-red-600')
    }

    toast.textContent = message
    document.body.appendChild(toast)

    // Animate in
    requestAnimationFrame(() => {
      toast.classList.remove('translate-x-full', 'opacity-0')
    })

    // Remove after 3 seconds
    setTimeout(() => {
      toast.classList.add('translate-x-full', 'opacity-0')
      setTimeout(() => {
        if (document.body.contains(toast)) {
          document.body.removeChild(toast)
        }
      }, 300)
    }, 3000)
  }


  // Print page
  print(event) {
    event.preventDefault()
    window.print()
  }
};
