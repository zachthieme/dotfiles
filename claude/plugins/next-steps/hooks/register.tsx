import { atom, read, update } from 'claude-code'
import type { EngineInterface, Register } from 'claude-code'

import type { Steps } from '../types'

// The band draws from session state; $.store is the durable copy that
// survives /clear and new sessions. Steps are kept per project root.
const steps = atom({ plugin: 'next-steps', key: 'steps' } as const, [])

type Host = EngineInterface

const storeKey = async ($: Host) => `steps:${await $.session.root()}`

const load = async ($: Host): Promise<Steps> => {
  const saved = await $.store.get(await storeKey($))
  return Array.isArray(saved) ? saved.filter(s => typeof s === 'string') : []
}

// Reload the session copy from the store (after /clear, or another session's edit).
const sync = async ($: Host) => {
  const saved = await load($)
  await update($, steps, () => saved)
  return saved
}

// Read-modify-write against the store, then mirror into session state.
const change = async ($: Host, fn: (list: Steps) => Steps) => {
  const next = fn(await load($))
  const key = await storeKey($)
  if (next.length === 0) await $.store.delete(key)
  else await $.store.set(key, next)
  await update($, steps, () => next)
  return next
}

const format = (list: Steps) =>
  list.length === 0
    ? 'No next steps for this project.'
    : list.map((s, i) => `${i + 1}. ${s}`).join('\n')

// /next output goes out through $.ui.log rather than the command's `text`,
// which the host prefixes with the plugin name ("next-steps: ...").
const report = (list: Steps) =>
  list.length === 0
    ? format(list)
    : `${list.length} next step${list.length === 1 ? '' : 's'}:\n${format(list)}`

// Parses "2", "1,3" or "1 3" into zero-based indices.
const indices = (text: string) =>
  text
    .split(/[\s,]+/)
    .filter(Boolean)
    .map(n => Number(n) - 1)
    .filter(n => Number.isInteger(n) && n >= 0)

const USAGE = [
  '/next              list next steps',
  '/next <text>       add a step',
  '/next done <n...>  complete step(s) by number',
  '/next clear        remove all steps',
].join('\n')

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    await $.command.register({
      name: 'next',
      description: 'Next steps for this project: list, add <text>, done <n>, clear',
    })
    await $.tool.register({
      name: 'add',
      description:
        "Save next steps for this project so the user remembers them after the session ends. They persist across /clear and new sessions and show above the prompt. Use when the user asks to note, remember or save a next step / todo for later.",
      inputSchema: {
        type: 'object',
        properties: {
          steps: {
            type: 'array',
            items: { type: 'string' },
            description: 'One short, actionable line per step',
          },
        },
        required: ['steps'],
      },
    })
    await $.tool.register({
      name: 'list',
      description: "List this project's saved next steps, numbered.",
    })
    await $.tool.register({
      name: 'done',
      description:
        'Mark saved next steps complete (removes them). Only when the user says a step is done or asks to remove it.',
      inputSchema: {
        type: 'object',
        properties: {
          numbers: {
            type: 'array',
            items: { type: 'integer' },
            description: '1-based step numbers, as list shows them',
          },
        },
        required: ['numbers'],
      },
    })
    await sync($)
    return next(e)
  })

  // Cheap re-sync each prompt: covers /clear resetting session state and
  // edits from another session in the same project.
  on('prompt.submit', async ($, e, next) => {
    await sync($)
    return next(e)
  }).catch(($, e, next) => next(e))

  on('command.run', { command: 'next' }, async ($, e) => {
    // Remote Control clients (the phone/desktop app) only get the command's
    // output row, not $.ui.log lines, so answer with `text` there.
    const show = (text: string) => {
      if (e.origin?.kind === 'bridge') return { text }
      $.ui.log(text)
      return {}
    }
    const args = e.args.trim()
    const [verb, ...rest] = args.split(/\s+/)

    if (args === '') return show(report(await sync($)))
    if (verb === 'help') return show(USAGE)
    if (verb === 'clear') {
      await change($, () => [])
      return show('Cleared next steps.')
    }
    if (verb === 'done') {
      const drop = indices(rest.join(' '))
      if (drop.length === 0) return show(`Usage:\n${USAGE}`)
      const list = await change($, l => l.filter((_, i) => !drop.includes(i)))
      return show(report(list))
    }

    const list = await change($, l => [...l, args])
    return show(report(list))
  })

  on('tool.call', { tool: 'mcp__next-steps__add' }, async ($, e: any) => {
    const added: string[] = (Array.isArray(e.steps) ? e.steps : [])
      .map((s: unknown) => String(s).trim())
      .filter(Boolean)
    const list = await change($, l => [...l, ...added])
    return { result: format(list) }
  }).catch(($, e, next) =>
    next.called ? next(e) : { deny: `${$.plugin.name}: could not read or save next steps.` },
  )

  on('tool.call', { tool: 'mcp__next-steps__list' }, async $ => ({
    result: format(await load($)),
  })).catch(($, e, next) =>
    next.called ? next(e) : { deny: `${$.plugin.name}: could not read or save next steps.` },
  )

  on('tool.call', { tool: 'mcp__next-steps__done' }, async ($, e: any) => {
    const drop = (Array.isArray(e.numbers) ? e.numbers : [])
      .map((n: unknown) => Number(n) - 1)
    const list = await change($, l => l.filter((_, i) => !drop.includes(i)))
    return { result: format(list) }
  }).catch(($, e, next) =>
    next.called ? next(e) : { deny: `${$.plugin.name}: could not read or save next steps.` },
  )

  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    const list = await read($, steps)
    if (e.props.hasSurvey || list.length === 0) return next(e)

    const { Box, Text } = $.ui.resolve(e)

    return (
      <Box flexDirection="column">
        <Text dimColor>Next steps</Text>
        {list.map((step, i) => (
          <Text key={`step-${i}`}>
            {i + 1}. {step}
          </Text>
        ))}
      </Box>
    )
  })
}
