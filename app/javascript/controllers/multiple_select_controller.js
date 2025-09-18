import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["counter"]
  static values = { max: Number }

  connect() {
    this.maxValue = parseInt(this.element.dataset.multipleSelectMax) || null
    this.updateCount()
    // Initialiser le total de points à la connexion
    this.updatePlatrerieTotal()
  }

  updateCount() {
    const checkboxes = this.element.querySelectorAll('input[type="checkbox"]')
    const checkedBoxes = this.element.querySelectorAll('input[type="checkbox"]:checked')

    // Update counter
    if (this.hasCounterTarget) {
      this.counterTarget.textContent = checkedBoxes.length
    }

    // Only apply max limit if maxValue is set (not null)
    if (this.maxValue !== null) {
      // Disable unchecked boxes if max reached
      if (checkedBoxes.length >= this.maxValue) {
        checkboxes.forEach(box => {
          if (!box.checked) {
            box.disabled = true
            box.closest('label').classList.add('opacity-50', 'cursor-not-allowed')
          }
        })
      } else {
        checkboxes.forEach(box => {
          box.disabled = false
          box.closest('label').classList.remove('opacity-50', 'cursor-not-allowed')
        })
      }
    } else {
      // No max limit - keep all checkboxes enabled
      checkboxes.forEach(box => {
        box.disabled = false
        box.closest('label').classList.remove('opacity-50', 'cursor-not-allowed')
      })
    }

    // Update hidden field with selected values
    this.updateHiddenField()

    // Enable/disable submit button
    this.updateSubmitButton()
  }

  updateHiddenField() {
    const checkedBoxes = this.element.querySelectorAll('input[type="checkbox"]:checked')
    const values = Array.from(checkedBoxes).map(box => box.value)
    const labels = Array.from(checkedBoxes).map(box => box.dataset.label)

    // Find or create hidden fields
    let codeField = document.getElementById('answer_value')

    if (codeField) {
      codeField.value = labels.join(', ')
    }

    // Calculer le total des points pour la plâtrerie
    this.updatePlatrerieTotal()
  }

  updatePlatrerieTotal() {
    const totalPointsElement = document.getElementById('platrerie_total_points')
    if (!totalPointsElement) return // Pas une question de plâtrerie

    const checkedBoxes = this.element.querySelectorAll('input[type="checkbox"]:checked')
    let totalPoints = 0

    console.log('Updating platrerie total, checked boxes:', checkedBoxes.length)

    checkedBoxes.forEach(box => {
      const points = parseFloat(box.dataset.points) || 0
      totalPoints += points
      console.log('Box points:', points, 'Total so far:', totalPoints)
    })

    console.log('Final total points:', totalPoints)
    totalPointsElement.textContent = totalPoints.toFixed(1)
  }

  updateSubmitButton() {
    const submitButton = document.querySelector('button[type="submit"]')
    const checkedBoxes = this.element.querySelectorAll('input[type="checkbox"]:checked')

    if (submitButton) {
      if (checkedBoxes.length > 0) {
        submitButton.disabled = false
      } else {
        submitButton.disabled = true
      }
    }
  }
}