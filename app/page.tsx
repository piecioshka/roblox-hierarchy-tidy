import { ExplorerDemo } from '@/components/explorer-demo'

const REPO = 'https://github.com/piecioshka/roblox-hierarchy-tidy'

const FEATURES = [
  {
    title: 'Find and select',
    body: 'Filter by name fragment and class across the Workspace, your selection, ServerScriptService or StarterGui. One button selects every sibling that shares a name.',
    detail: 'BasePart · Script · 500 hits per query',
  },
  {
    title: 'Grouping',
    body: 'Wrap the selection in a Folder or a Model, split it by class into Parts and Scripts, or unpack a container and send its children up a level.',
    detail: 'Folder · Model · split · unpack',
  },
  {
    title: 'Renaming',
    body: 'Number a whole selection from one pattern. {n} is the counter and {class} the class name; you set where it starts and how many digits it pads to.',
    detail: 'Wall_{n} → Wall_001',
  },
  {
    title: 'Tidy up',
    body: 'Delete empty Folders, Models and Configurations from the leaves up, so nested empty chains go too. Sort GuiObject children into alphabetical LayoutOrder.',
    detail: 'selection · whole Workspace',
  },
]

const SHORTCUTS = [
  ['Hierarchy Tidy: group into Folder', 'Moves the selected objects into a new Folder'],
  ['Hierarchy Tidy: unpack container', 'Sends the children up and removes the empty container'],
  ['Hierarchy Tidy: remove empty containers', 'Clears empty Folders and Models in the selection'],
]

function GithubMark() {
  return (
    <svg viewBox="0 0 16 16" aria-hidden="true" className="size-4">
      <path
        fill="currentColor"
        d="M8 0C3.58 0 0 3.58 0 8a8 8 0 0 0 5.47 7.59c.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82a7.4 7.4 0 0 1 2-.27c.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.01 8.01 0 0 0 16 8c0-4.42-3.58-8-8-8Z"
      />
    </svg>
  )
}

function Header() {
  return (
    <header className="border-b border-rule/60">
      <div className="mx-auto flex max-w-5xl items-center justify-between px-6 py-5">
        <div className="flex items-baseline gap-2.5">
          <span className="font-display text-lg font-semibold tracking-tight">Hierarchy Tidy</span>
          <span className="hidden font-mono text-[11px] text-haze sm:inline">
            for Roblox Studio
          </span>
        </div>
        <a
          href={REPO}
          className="flex items-center gap-2 rounded-md px-3 py-1.5 text-sm text-haze transition-colors hover:bg-shelf hover:text-bone"
        >
          <GithubMark />
          GitHub
        </a>
      </div>
    </header>
  )
}

function Hero() {
  return (
    <section className="mx-auto max-w-5xl px-6 pt-16 pb-20 lg:pt-24">
      <div className="grid items-center gap-14 lg:grid-cols-[1fr_minmax(0,26rem)] lg:gap-16">
        <div>
          <p className="font-mono text-[11px] tracking-[0.22em] text-tidy uppercase">
            Roblox Studio plugin
          </p>
          <h1 className="mt-5 font-display text-4xl leading-[1.05] font-semibold tracking-tight text-balance sm:text-5xl lg:text-6xl">
            Your Explorer is a pile of Parts.
          </h1>
          <p className="mt-6 max-w-xl text-lg leading-relaxed text-haze text-pretty">
            Hierarchy Tidy finds the duplicates, groups them by class, numbers the names and throws
            out the empty folders. One docked panel, and every change undoes with Ctrl+Z.
          </p>
          <div className="mt-9 flex flex-wrap gap-3">
            <a
              href="#install"
              className="rounded-md bg-tidy px-5 py-2.5 text-sm font-medium text-ink transition-colors hover:bg-tidy/90"
            >
              Install the plugin
            </a>
            <a
              href={REPO}
              className="flex items-center gap-2 rounded-md border border-rule px-5 py-2.5 text-sm font-medium text-bone transition-colors hover:bg-shelf"
            >
              <GithubMark />
              Read the source
            </a>
          </div>
        </div>

        <div>
          <ExplorerDemo />
          <p className="mt-4 text-center font-mono text-[11px] text-haze">
            Press Tidy up — this is the whole plugin in one move.
          </p>
        </div>
      </div>
    </section>
  )
}

function Features() {
  return (
    <section className="border-t border-rule/60 bg-panel/40">
      <div className="mx-auto max-w-5xl px-6 py-20">
        <h2 className="font-display text-2xl font-semibold tracking-tight">
          Four sections, one panel
        </h2>
        <p className="mt-3 max-w-xl text-haze">
          The panel docks on the right of Studio and follows its light or dark theme. Field values
          stick around after a restart.
        </p>

        <div className="mt-12 grid gap-px overflow-hidden rounded-xl border border-rule bg-rule sm:grid-cols-2">
          {FEATURES.map((feature) => (
            <article key={feature.title} className="bg-ink p-7">
              <h3 className="font-display text-lg font-semibold tracking-tight">{feature.title}</h3>
              <p className="mt-3 leading-relaxed text-haze">{feature.body}</p>
              <p className="mt-5 font-mono text-[11px] text-tidy/80">{feature.detail}</p>
            </article>
          ))}
        </div>
      </div>
    </section>
  )
}

function Snippet({ label, lines }: { label: string; lines: string[] }) {
  return (
    <div className="overflow-hidden rounded-xl border border-rule bg-panel">
      <div className="border-b border-rule bg-shelf px-4 py-2.5">
        <span className="font-mono text-[11px] tracking-[0.14em] text-haze">{label}</span>
      </div>
      <pre className="px-4 py-4">
        {/* Wraps instead of scrolling: a soft-wrapped line still copies as one line. */}
        <code className="font-mono text-[12.5px] leading-relaxed break-words whitespace-pre-wrap text-bone">
          {lines.join('\n')}
        </code>
      </pre>
    </div>
  )
}

function Install() {
  return (
    <section id="install" className="scroll-mt-8 border-t border-rule/60">
      <div className="mx-auto max-w-5xl px-6 py-20">
        <h2 className="font-display text-2xl font-semibold tracking-tight">Install it</h2>
        <p className="mt-3 max-w-2xl text-haze">
          The plugin ships as source, so you build it yourself with{' '}
          <a
            href="https://rojo.space"
            className="text-bone underline decoration-rule underline-offset-4 hover:decoration-tidy"
          >
            Rojo
          </a>
          . Build the file, drop it in Studio&rsquo;s plugins folder, restart Studio.
        </p>

        <div className="mt-10 grid gap-5 md:grid-cols-2">
          <Snippet
            label="Windows"
            lines={[
              'cd roblox\\hierarchy-tidy',
              'rojo build -o HierarchyTidy.rbxmx',
              'Copy-Item HierarchyTidy.rbxmx "$env:LOCALAPPDATA\\Roblox\\Plugins"',
            ]}
          />
          <Snippet
            label="macOS"
            lines={[
              'cd roblox/hierarchy-tidy',
              'rojo build -o HierarchyTidy.rbxmx',
              'cp HierarchyTidy.rbxmx ~/Documents/Roblox/Plugins/',
            ]}
          />
        </div>

        <div className="mt-6 grid gap-5 md:grid-cols-2">
          <p className="text-sm leading-relaxed text-haze">
            No plugins folder yet? Open Studio and use{' '}
            <span className="text-bone">Plugins → Plugins Folder</span> to create and reveal it. A{' '}
            <span className="text-bone">Hierarchy Tidy</span> toolbar appears after the restart.
          </p>
          <p className="text-sm leading-relaxed text-haze">
            Working on the plugin itself? Run{' '}
            <span className="font-mono text-bone">rojo serve</span> and connect from the Rojo plugin
            in Studio — edits land without a rebuild.
          </p>
        </div>
      </div>
    </section>
  )
}

function Shortcuts() {
  return (
    <section className="border-t border-rule/60 bg-panel/40">
      <div className="mx-auto max-w-5xl px-6 py-20">
        <h2 className="font-display text-2xl font-semibold tracking-tight">
          Bind the ones you use
        </h2>
        <p className="mt-3 max-w-2xl text-haze">
          Three actions register under{' '}
          <span className="text-bone">File → Advanced → Customize Shortcuts</span>. They arrive
          unbound, act on the current Explorer selection and log the result to Output.
        </p>

        <ul className="mt-10 divide-y divide-rule overflow-hidden rounded-xl border border-rule bg-ink">
          {SHORTCUTS.map(([name, what]) => (
            <li
              key={name}
              className="flex flex-col gap-1 px-6 py-5 sm:flex-row sm:items-baseline sm:gap-8"
            >
              <span className="font-mono text-[13px] text-bone sm:w-80 sm:shrink-0">{name}</span>
              <span className="text-sm text-haze">{what}</span>
            </li>
          ))}
        </ul>
      </div>
    </section>
  )
}

function Footer() {
  return (
    <footer className="border-t border-rule/60">
      <div className="mx-auto flex max-w-5xl flex-col gap-3 px-6 py-10 sm:flex-row sm:items-center sm:justify-between">
        <p className="font-mono text-[11px] text-haze">Built with Rojo and Luau.</p>
        <a
          href={REPO}
          className="flex items-center gap-2 text-sm text-haze transition-colors hover:text-bone"
        >
          <GithubMark />
          piecioshka/roblox-hierarchy-tidy
        </a>
      </div>
    </footer>
  )
}

export default function Page() {
  return (
    <div className="min-h-screen">
      <Header />
      <main>
        <Hero />
        <Features />
        <Install />
        <Shortcuts />
      </main>
      <Footer />
    </div>
  )
}
