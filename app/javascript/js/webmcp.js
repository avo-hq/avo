// WebMCP: the browser's own AI agent reads tools off the page through `document.modelContext` (Chrome,
// behind chrome://flags/#enable-webmcp-testing today; `navigator.modelContext` in the origin-trial builds).
// Every Avo tool goes through here: core's search tool, avo-mcp_server's write tools, and any a
// plugin or host app registers. Avo's own forms carry no tool attributes.
//
// A registration is scoped to the AbortSignal passed with it, so a tool lives exactly as long as the
// element that declared it — under Turbo, the page. Pass the signal of a controller aborted in
// `disconnect()`; the webmcp-tool controller is the worked example.
function modelContext() {
  if (window.Avo?.configuration?.webmcp?.enabled === false) return null

  const context = document.modelContext ?? navigator.modelContext

  return typeof context?.registerTool === 'function' ? context : null
}

export function supported() {
  return modelContext() !== null
}

// Resolves to true when registered, false when this browser (or this app) has no WebMCP. `execute` may return a
// string, a plain object, or a ready `{ content: [...] }` — the agent always receives the last.
export async function registerTool({ execute, ...definition }, options = {}) {
  const context = modelContext()

  if (!context) return false

  await context.registerTool(
    { ...definition, execute: async (...args) => asContent(await execute(...args)) },
    options,
  )

  return true
}

function asContent(result) {
  if (result && typeof result === 'object' && Array.isArray(result.content)) return result

  const text = typeof result === 'string' ? result : JSON.stringify(result ?? null)

  return { content: [{ type: 'text', text }] }
}
