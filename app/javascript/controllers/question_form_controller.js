import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["submitButton", "answerValue", "totalElement"]
  static classes = ["disabled"]

  connect() {
    this.checkSubmitButtonState()
  }

  // Enable submit button
  enableSubmit() {
    if (this.hasSubmitButtonTarget) {
      this.submitButtonTarget.disabled = false
    }
  }

  // Update single choice total points
  updateSingleChoiceTotal(event) {
    const selectedRadio = event.target
    if (this.hasTotalElementTarget && selectedRadio.checked) {
      const points = parseFloat(selectedRadio.dataset.points) || 0
      this.totalElementTarget.textContent = points + ' points'

      // Update answer value
      if (this.hasAnswerValueTarget) {
        this.answerValueTarget.value = selectedRadio.getAttribute('data-label') || ''
      }

      this.enableSubmit()
    }
  }

  // Change quantity with + and - buttons
  changeQuantity(event) {
    const button = event.target
    const optionCode = button.dataset.optionCode
    const delta = parseInt(button.dataset.delta)
    const input = document.getElementById(`quantity_${optionCode}`)

    if (input) {
      let currentValue = parseInt(input.value) || 0
      let newValue = currentValue + delta

      // Limit between 0 and 20
      newValue = Math.max(0, Math.min(20, newValue))

      input.value = newValue

      // Update subtotal
      this.updateSubtotal(optionCode)
      this.updateQuantityTotal()
      this.enableSubmit()
    }
  }

  // Update subtotal for a specific option
  updateSubtotal(optionCode) {
    const input = document.getElementById(`quantity_${optionCode}`)
    const subtotalSpan = document.getElementById(`subtotal_${optionCode}`)

    if (input && subtotalSpan) {
      const quantity = parseInt(input.value) || 0
      const points = parseFloat(input.dataset.points) || 0
      const subtotal = quantity * points
      subtotalSpan.textContent = subtotal
    }
  }

  // Update total quantity and points
  updateQuantityTotal() {
    const questionCode = this.data.get("questionCode")
    if (!questionCode) return

    const totalElementId = this.getTotalElementId(questionCode)
    const quantities = this.getQuantityConfig(questionCode)

    let total = 0
    let details = []

    quantities.forEach(item => {
      const input = document.getElementById(`quantity_${item.code}`)
      if (input) {
        const quantity = parseInt(input.value) || 0
        const points = item.points * quantity
        total += points

        if (quantity > 0) {
          details.push({
            code: item.code,
            label: item.label,
            quantity: quantity,
            points: points
          })
        }
      }
    })

    // Update total display
    const totalSpan = document.getElementById(totalElementId)
    if (totalSpan) {
      totalSpan.textContent = total
    }

    // Update answer value with JSON
    if (this.hasAnswerValueTarget && details.length > 0) {
      const answerData = {
        type: 'multiple_quantities',
        details: details,
        total_points: total
      }
      this.answerValueTarget.value = JSON.stringify(answerData)
    }
  }

  // Get total element ID based on question code
  getTotalElementId(questionCode) {
    switch(questionCode) {
      case 'QP4': return 'total_passages_mur'
      case 'QP5': return 'total_chevetre'
      case 'QP6': return 'total_platrerie'
      default: return 'total_question'
    }
  }

  // Get quantity configuration based on question code
  getQuantityConfig(questionCode) {
    const configs = {
      'QP4': [
        { code: 'RP1', label: 'Traversée mur simple', points: 0.5 },
        { code: 'RP2', label: 'Traversée mur double', points: 1.0 },
        { code: 'RP3', label: 'Traversée mur complexe', points: 1.5 }
      ],
      'QP5': [
        { code: 'RP1', label: 'Chevêtre toiture', points: 1.0 },
        { code: 'RP2', label: 'Chevêtre plancher', points: 1.0 }
      ],
      'QP6': [
        { code: 'RP1', label: 'Rebouchage simple', points: 1.0 },
        { code: 'RP2', label: 'Rebouchage complexe', points: 1.5 },
        { code: 'RP3', label: 'Habillage BA13', points: 0.75 },
        { code: 'RP4', label: 'Ragréage', points: 0.5 },
        { code: 'RP5', label: 'Enduit', points: 0.75 },
        { code: 'RP6', label: 'Peinture', points: 1.5 },
        { code: 'RP7', label: 'Reprise électrique', points: 2.5 },
        { code: 'RP8', label: 'Reprise plomberie', points: 3.5 },
        { code: 'RP9', label: 'Pose carrelage', points: 1.0 },
        { code: 'RP10', label: 'Pose parquet', points: 1.5 },
        { code: 'RP11', label: 'Nettoyage', points: 0.5 }
      ]
    }
    return configs[questionCode] || []
  }

  // Check submit button state for different input types
  checkSubmitButtonState() {
    // For radio buttons
    const radioButtons = this.element.querySelectorAll('input[type="radio"]')
    if (radioButtons.length > 0) {
      const hasChecked = this.element.querySelector('input[type="radio"]:checked')
      if (hasChecked) this.enableSubmit()
    }

    // For number inputs
    const numberInput = this.element.querySelector('input[type="number"]')
    if (numberInput && numberInput.value) {
      this.enableSubmit()
    }

    // For checkboxes
    const checkboxes = this.element.querySelectorAll('input[type="checkbox"]')
    if (checkboxes.length > 0) {
      const checkedBoxes = this.element.querySelectorAll('input[type="checkbox"]:checked')
      if (checkedBoxes.length > 0) this.enableSubmit()
    }

    // For quantity inputs
    const quantityInputs = this.element.querySelectorAll('input[name^="quantities"]')
    if (quantityInputs.length > 0) {
      let hasQuantity = false
      quantityInputs.forEach(input => {
        if (parseInt(input.value) > 0) hasQuantity = true
      })
      if (hasQuantity) this.enableSubmit()
    }
  }

  // Handle input changes
  handleInputChange(event) {
    const input = event.target

    if (input.type === 'radio') {
      this.updateSingleChoiceTotal(event)
    } else if (input.type === 'number') {
      if (this.hasAnswerValueTarget) {
        this.answerValueTarget.value = input.value
      }
      this.enableSubmit()
    } else if (input.type === 'checkbox') {
      this.updateMultipleChoice()
    } else if (input.name && input.name.startsWith('quantities')) {
      const optionCode = input.name.match(/\[(.*?)\]/)[1]
      this.updateSubtotal(optionCode)
      this.updateQuantityTotal()
      this.enableSubmit()
    }
  }

  // Update multiple choice selections
  updateMultipleChoice() {
    const checkedBoxes = this.element.querySelectorAll('input[type="checkbox"]:checked')
    const codes = Array.from(checkedBoxes).map(cb => cb.value)

    if (this.hasAnswerValueTarget) {
      this.answerValueTarget.value = JSON.stringify(codes)
    }

    // Update total points for multiple choice
    let totalPoints = 0
    checkedBoxes.forEach(checkbox => {
      const points = parseFloat(checkbox.dataset.points) || 0
      totalPoints += points
    })

    const totalElement = document.getElementById('platrerie_total_points')
    if (totalElement) {
      totalElement.textContent = totalPoints
    }

    this.enableSubmit()
  }
}