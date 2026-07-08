import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = {
    chartId: String,
  }

  toggleSlice({ params, currentTarget }) {
    const chart = this.chart()
    if (!chart) return

    chart.toggleDataVisibility(params.index)
    chart.update()

    currentTarget.classList.toggle(
      'distribution-chart__row--inactive',
      !chart.getDataVisibility(params.index),
    )
  }

  highlightSlice({ params }) {
    const chart = this.chart()
    if (!chart || !chart.getDataVisibility(params.index)) return

    const dataset = chart.data.datasets[0]
    const offsets = new Array(dataset.data.length).fill(0)
    offsets[params.index] = 32
    dataset.offset = offsets
    chart.update()
  }

  clearHighlight() {
    const chart = this.chart()
    if (!chart) return

    chart.data.datasets[0].offset = 0
    chart.update()
  }

  chart() {
    const kick = window.Chartkick?.charts?.[this.chartIdValue]

    return kick?.getChartObject?.() ?? null
  }
}
