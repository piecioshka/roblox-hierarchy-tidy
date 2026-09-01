'use client'

import { useState } from 'react'

type Kind = 'workspace' | 'part' | 'script' | 'folder' | 'model'

type Row = {
  depth: number
  name: string
  kind: Kind
  flag?: string
}

// Both trees hold the same number of rows, so tidying reads as a
// rearrangement of the Explorer rather than a jump to another panel.
const MESSY: Row[] = [
  { depth: 0, name: 'Workspace', kind: 'workspace' },
  { depth: 1, name: 'Part', kind: 'part', flag: 'duplicate' },
  { depth: 1, name: 'Part', kind: 'part', flag: 'duplicate' },
  { depth: 1, name: 'Part', kind: 'part', flag: 'duplicate' },
  { depth: 1, name: 'Part', kind: 'part', flag: 'duplicate' },
  { depth: 1, name: 'Script', kind: 'script', flag: 'duplicate' },
  { depth: 1, name: 'Script', kind: 'script', flag: 'duplicate' },
  { depth: 1, name: 'Model', kind: 'model' },
  { depth: 1, name: 'Folder', kind: 'folder', flag: 'empty' },
  { depth: 1, name: 'Folder', kind: 'folder', flag: 'empty' },
]

const TIDY: Row[] = [
  { depth: 0, name: 'Workspace', kind: 'workspace' },
  { depth: 1, name: 'Parts', kind: 'folder' },
  { depth: 2, name: 'Wall_001', kind: 'part' },
  { depth: 2, name: 'Wall_002', kind: 'part' },
  { depth: 2, name: 'Wall_003', kind: 'part' },
  { depth: 2, name: 'Wall_004', kind: 'part' },
  { depth: 1, name: 'Scripts', kind: 'folder' },
  { depth: 2, name: 'Handler_001', kind: 'script' },
  { depth: 2, name: 'Handler_002', kind: 'script' },
  { depth: 1, name: 'Model', kind: 'model' },
]

// Written out rather than computed so Tailwind can see every class.
const STAGGER = [
  'delay-[0ms]',
  'delay-[35ms]',
  'delay-[70ms]',
  'delay-[105ms]',
  'delay-[140ms]',
  'delay-[175ms]',
  'delay-[210ms]',
  'delay-[245ms]',
  'delay-[280ms]',
  'delay-[315ms]',
]

const INDENT = ['pl-3', 'pl-8', 'pl-13']

function Glyph({ kind, tinted }: { kind: Kind; tinted: boolean }) {
  const tone = tinted ? 'text-tidy' : 'text-haze'

  if (kind === 'folder') {
    return (
      <svg viewBox="0 0 16 16" aria-hidden="true" className={`size-3.5 shrink-0 ${tone}`}>
        <path
          d="M1.5 4.2c0-.6.5-1.1 1.1-1.1h3.1l1.4 1.6h6.3c.6 0 1.1.5 1.1 1.1v6.4c0 .6-.5 1.1-1.1 1.1H2.6c-.6 0-1.1-.5-1.1-1.1V4.2Z"
          fill="currentColor"
          opacity="0.9"
        />
      </svg>
    )
  }

  if (kind === 'script') {
    return (
      <svg viewBox="0 0 16 16" aria-hidden="true" className={`size-3.5 shrink-0 ${tone}`}>
        <path d="M3.5 2h6L13 5.4V14H3.5V2Z" fill="currentColor" opacity="0.35" />
        <path
          d="M5.5 8h5M5.5 10.5h5"
          stroke="currentColor"
          strokeWidth="1.2"
          strokeLinecap="round"
        />
      </svg>
    )
  }

  if (kind === 'model') {
    return (
      <svg viewBox="0 0 16 16" aria-hidden="true" className={`size-3.5 shrink-0 ${tone}`}>
        <path
          d="M8 1.8 14 5v6l-6 3.2L2 11V5l6-3.2Z"
          fill="none"
          stroke="currentColor"
          strokeWidth="1.2"
          strokeLinejoin="round"
        />
        <path
          d="M2 5l6 3.2L14 5M8 8.2v6"
          stroke="currentColor"
          strokeWidth="1.2"
          strokeLinejoin="round"
        />
      </svg>
    )
  }

  if (kind === 'workspace') {
    return (
      <svg viewBox="0 0 16 16" aria-hidden="true" className={`size-3.5 shrink-0 ${tone}`}>
        <circle cx="8" cy="8" r="6" fill="none" stroke="currentColor" strokeWidth="1.2" />
        <path
          d="M2.4 6.4h11.2M2.4 9.6h11.2M8 2.2c1.7 1.7 2.6 3.7 2.6 5.8S9.7 12.1 8 13.8C6.3 12.1 5.4 10.1 5.4 8s.9-4.1 2.6-5.8Z"
          fill="none"
          stroke="currentColor"
          strokeWidth="1.2"
        />
      </svg>
    )
  }

  return (
    <svg viewBox="0 0 16 16" aria-hidden="true" className={`size-3.5 shrink-0 ${tone}`}>
      <rect x="3" y="3" width="10" height="10" rx="1.5" fill="currentColor" opacity="0.55" />
    </svg>
  )
}

function Tree({ rows, visible, tidy }: { rows: Row[]; visible: boolean; tidy: boolean }) {
  return (
    <ul
      aria-hidden={!visible}
      className={`absolute inset-x-2 top-2 transition-opacity duration-300 ${
        visible ? 'opacity-100' : 'pointer-events-none opacity-0'
      }`}
    >
      {rows.map((row, index) => (
        <li
          key={`${row.name}-${index}`}
          className={`flex h-8 items-center gap-2 rounded-sm transition-all duration-500 ease-out motion-reduce:transition-none motion-reduce:delay-0 ${
            INDENT[row.depth]
          } ${STAGGER[index]} ${visible ? 'translate-x-0 opacity-100' : 'translate-x-3 opacity-0'}`}
        >
          <Glyph kind={row.kind} tinted={tidy && row.kind === 'folder'} />
          <span className="font-mono text-[13px] text-bone">{row.name}</span>
          {row.flag ? (
            <span className="ml-auto rounded-full border border-flag/40 px-2 py-px font-mono text-[10px] tracking-wide text-flag">
              {row.flag}
            </span>
          ) : null}
        </li>
      ))}
    </ul>
  )
}

export function ExplorerDemo() {
  const [tidy, setTidy] = useState(false)

  return (
    <figure className="overflow-hidden rounded-xl border border-rule bg-panel shadow-2xl shadow-black/40">
      <div className="flex items-center justify-between border-b border-rule bg-shelf px-4 py-2.5">
        <span className="font-mono text-[11px] uppercase tracking-[0.18em] text-haze">
          Explorer
        </span>
        <span className="font-mono text-[11px] text-haze">10 objects</span>
      </div>

      <div className="relative h-84">
        <Tree rows={MESSY} visible={!tidy} tidy={false} />
        <Tree rows={TIDY} visible={tidy} tidy />
      </div>

      <div className="border-t border-rule px-4 py-4">
        <button
          type="button"
          onClick={() => setTidy((current) => !current)}
          className={`w-full rounded-md px-4 py-2.5 font-medium text-sm transition-colors ${
            tidy
              ? 'border border-rule bg-shelf text-bone hover:bg-rule'
              : 'bg-tidy text-ink hover:bg-tidy/90'
          }`}
        >
          {tidy ? 'Undo — Ctrl+Z' : 'Tidy up'}
        </button>
        <p aria-live="polite" className="mt-3 font-mono text-[11px] leading-relaxed text-haze">
          {tidy
            ? 'Grouped 6 objects, renamed 6, removed 2 empty containers.'
            : 'Ready. Every operation supports Ctrl+Z.'}
        </p>
      </div>
    </figure>
  )
}
