import { expect, mock, test } from 'claude-code/testing'

const BAND = {
  plugin: 'next-steps',
  component: 'AbovePrompt',
  props: { hasSurvey: false, isWorking: false, maxRows: 20, columns: 80 },
} as const

// Stand in for the engine beneath the plugin: a project root, an in-memory
// store, and an empty default band.
const world = (on: any) => {
  mock.store(on)
  on('session.root', () => ({ value: '/proj' }))
  on('session.repo', () => ({ value: null }))
  on('ui.log', (_: any, e: any) => {
    logged = e.text
    return { value: undefined }
  })
  on('ui.render', ($: any, e: any) => {
    const { Box } = $.ui.resolve(e)
    return <Box />
  })
}

// /next shows its output with $.ui.log; capture the last line logged.
let logged: string | undefined
const next = async ($: any, args: string) => {
  logged = undefined
  await $.command.run({ command: 'next', args })
  return logged
}

test('/next adds, lists, completes and clears', async ($, on) => {
  world(on)

  expect(await next($, '')).toBe('No next steps for this repo.')
  await next($, 'push main')
  expect(await next($, 'delete stale branches')).toBe(
    '2 next steps:\n1. push main\n2. delete stale branches',
  )
  expect(await next($, 'done 1')).toBe('1 next step:\n1. delete stale branches')
  await next($, 'clear')
  expect(await next($, '')).toBe('No next steps for this repo.')
})

test('steps saved earlier for this root are read back (survive /clear)', async ($, on) => {
  mock.store(on, {
    'steps:/proj': ['restart tailscale'],
    'steps:/elsewhere': ['other project'],
  })
  on('session.root', () => ({ value: '/proj' }))
  on('session.repo', () => ({ value: null }))
  on('ui.log', (_: any, e: any) => {
    logged = e.text
    return { value: undefined }
  })

  expect(await next($, '')).toBe('1 next step:\n1. restart tailscale')
})

test('model tools add, list and complete', async ($, on) => {
  world(on)

  const added = await $.tool.call({
    tool: 'mcp__next-steps__add',
    steps: ['a', ' b ', ''],
  } as any)
  expect((added as any).result).toBe('1. a\n2. b')

  const done = await $.tool.call({
    tool: 'mcp__next-steps__done',
    numbers: [1],
  } as any)
  expect((done as any).result).toBe('1. b')

  const listed = await $.tool.call({ tool: 'mcp__next-steps__list' } as any)
  expect((listed as any).result).toBe('1. b')
})

test('band shows steps without Done buttons, on every surface', async ($, on) => {
  world(on)
  for (const surface of ['terminal', 'desktop'] as const) {
    await next($, 'clear')
    await next($, 'first')
    await next($, 'second')

    const ui = await $.ui.mount({ ...BAND, surface } as any)
    expect(await ui.find({ type: 'Text', text: /2\. second/ })).toBeDefined()
    expect(await ui.find({ type: 'Button' })).toBeUndefined()
    await ui.unmount()
  }
})

test('band stays out of the way with no steps', async ($, on) => {
  world(on)
  const ui = await $.ui.mount({ ...BAND, surface: 'terminal' } as any)
  expect(await ui.find({ type: 'Text', text: /Next steps/ })).toBeUndefined()
  await ui.unmount()
})

test('/next from the Remote Control app answers with text, not a log line', async ($, on) => {
  world(on)
  logged = undefined
  const r = await $.command.run({
    command: 'next',
    args: 'from phone',
    origin: { kind: 'bridge' },
  } as any)
  expect(r.text).toBe('1 next step:\n1. from phone')
  expect(logged).toBeUndefined()
})

test('steps are shared by every directory and worktree of one repo', async ($, on) => {
  mock.store(on, { 'steps:/repo': ['ship it'], 'steps:/repo/sub': ['stale'] })
  on('session.root', () => ({ value: '/repo-worktree/sub' }))
  on('session.repo', () => ({
    value: { root: '/repo', remote: null, internal: false, name: null },
  }))
  on('ui.log', (_: any, e: any) => {
    logged = e.text
    return { value: undefined }
  })

  expect(await next($, '')).toBe('1 next step:\n1. ship it')
  await next($, 'and tag it')

  const other = await $.tool.call({ tool: 'mcp__next-steps__list' } as any)
  expect((other as any).result).toBe('1. ship it\n2. and tag it')
})

test('different repos keep separate lists', async ($, on) => {
  mock.store(on, { 'steps:/a': ['for a'], 'steps:/b': ['for b'] })
  let root = '/a'
  on('session.root', () => ({ value: root }))
  on('session.repo', () => ({
    value: { root, remote: null, internal: false, name: null },
  }))
  on('ui.log', (_: any, e: any) => {
    logged = e.text
    return { value: undefined }
  })

  expect(await next($, '')).toBe('1 next step:\n1. for a')
  root = '/b'
  expect(await next($, '')).toBe('1 next step:\n1. for b')
})
