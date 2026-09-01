import { describe, expect, it } from 'vitest'
import { cn } from './utils'

describe('cn', () => {
  it('joins class names', () => {
    expect(cn('a', 'b')).toBe('a b')
  })

  it('drops falsy values', () => {
    expect(cn('a', false, undefined, null, 'b')).toBe('a b')
  })

  it('resolves conditional classes from objects', () => {
    expect(cn('a', { b: true, c: false })).toBe('a b')
  })

  it('lets the later tailwind class win a conflict', () => {
    expect(cn('px-2', 'px-4')).toBe('px-4')
  })
})
