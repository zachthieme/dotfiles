export type Steps = string[]

declare module 'claude-code' {
  interface PluginState {
    'next-steps': { steps: Steps }
  }
}
