#!/usr/bin/env node

/**
 * Builds CSS variables from design tokens JSON using Style Dictionary CLI
 *
 * Usage:
 *   node scripts/build-design-tokens.js
 *
 * Optional:
 *   INPUT_FILE=app/assets/stylesheets/design-tokens.json (default)
 *   OUTPUT_FILE=app/assets/stylesheets/css/design-tokens.css (default)
 *   CONFIG_FILE=config/style-dictionary.json (default)
 */

/* eslint-disable no-console */
/* eslint-disable import/no-extraneous-dependencies */
const { execSync } = require('child_process')
const path = require('path')
const fs = require('fs')
const { converter } = require('culori')

// Get configuration from environment variables
const INPUT_FILE = process.env.INPUT_FILE || 'app/assets/stylesheets/design-tokens.json'
const OUTPUT_FILE = process.env.OUTPUT_FILE || 'app/assets/stylesheets/css/design-tokens.css'
const CONFIG_FILE = process.env.CONFIG_FILE || 'config/style-dictionary.json'

// Validate input file exists
const inputPath = path.resolve(process.cwd(), INPUT_FILE)
if (!fs.existsSync(inputPath)) {
  console.error(`Error: Input file not found: ${INPUT_FILE}`)
  console.error(`Expected at: ${inputPath}`)
  process.exit(1)
}

// Validate config file exists
const configPath = path.resolve(process.cwd(), CONFIG_FILE)
if (!fs.existsSync(configPath)) {
  console.error(`Error: Config file not found: ${CONFIG_FILE}`)
  console.error(`Expected at: ${configPath}`)
  process.exit(1)
}

console.log('Building CSS variables from design tokens...')
console.log(`Input: ${INPUT_FILE}`)
console.log(`Output: ${OUTPUT_FILE}`)
console.log(`Config: ${CONFIG_FILE}`)
console.log('')

try {
  // Run Style Dictionary build command
  execSync(
    `style-dictionary build --config ${CONFIG_FILE}`,
    {
      stdio: 'inherit',
      cwd: process.cwd(),
    },
  )

  // Post-process: Remove spacing and radius variables from the output CSS
  const outputPath = path.resolve(process.cwd(), OUTPUT_FILE)
  if (fs.existsSync(outputPath)) {
    let cssContent = fs.readFileSync(outputPath, 'utf8')

    // Convert colors to OKLCH format
    const toOklch = converter('oklch')
    cssContent = cssContent.replace(
      /(--color-[^:]+):\s*([^;]+);/g,
      (match, varName, colorValue) => {
        const trimmedColor = colorValue.trim()
        // Skip if already OKLCH or not a color value
        if (trimmedColor.startsWith('oklch') || trimmedColor.startsWith('var(')) {
          return match
        }

        try {
          const oklchColor = toOklch(trimmedColor)
          if (oklchColor) {
            // Format OKLCH with rounded values: L and C to 2 decimals, H to 1 decimal
            const l = oklchColor.l != null ? oklchColor.l.toFixed(2) : '0'
            const c = oklchColor.c != null ? oklchColor.c.toFixed(2) : '0'
            const h = oklchColor.h != null ? oklchColor.h.toFixed(1) : 'none'
            const alpha = oklchColor.alpha != null && oklchColor.alpha !== 1
              ? ` / ${oklchColor.alpha.toFixed(2)}`
              : ''

            const formatted = `oklch(${l} ${c} ${h}${alpha})`

            return `${varName}: ${formatted};`
          }
        } catch (error) {
          // If conversion fails, keep original value
          console.warn(`Warning: Could not convert ${trimmedColor} to OKLCH, keeping original`)
        }

        return match
      },
    )

    // Remove uncommented lines containing spacing or radius variables
    cssContent = cssContent.replace(/^\s*--(spacing|radius)-[^:]*:[^;]*;?\s*$/gm, '')

    // Remove comment blocks that contain only spacing/radius variables
    cssContent = cssContent.replace(/\/\*[\s\S]*?\*\//g, (match) => {
      // Check if comment contains only spacing/radius variables
      const content = match.replace(/\/\*|\*\//g, '').trim()
      const lines = content.split('\n').map((l) => l.trim()).filter((l) => l)
      const allSpacingRadius = lines.length > 0 && lines.every((line) => (
        line.match(/^\s*--(spacing|radius)-/) || line === ''
      ))

      return allSpacingRadius ? '' : match
    })

    // Replace :root with @theme for Tailwind compatibility
    cssContent = cssContent.replace(/:root\s*{/g, '@theme {')

    // Clean up any double newlines that might result
    cssContent = cssContent.replace(/\n\n\n+/g, '\n\n')

    fs.writeFileSync(outputPath, cssContent, 'utf8')
    console.log('✓ Converted colors to OKLCH format')
    console.log('✓ Removed spacing and radius variables from output')
    console.log('✓ Replaced :root with @theme for Tailwind compatibility')
  }

  console.log('')
  console.log('✓ Successfully generated CSS variables!')
  console.log(`✓ Output file: ${OUTPUT_FILE}`)
} catch (error) {
  console.error('')
  console.error('✗ Failed to build design tokens')
  console.error(error.message)
  process.exit(1)
}
