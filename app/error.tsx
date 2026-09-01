'use client'

export default function ErrorBoundary({ reset }: { error: Error; reset: () => void }) {
  return (
    <div className="flex min-h-screen flex-col items-center justify-center px-6 text-center">
      <p className="font-mono text-[11px] tracking-[0.22em] text-tidy uppercase">Error</p>
      <h1 className="mt-5 font-display text-3xl font-semibold tracking-tight sm:text-4xl">
        Something broke on this page.
      </h1>
      <p className="mt-4 max-w-md text-haze">
        Try again — and if it keeps happening, open an issue on GitHub.
      </p>
      <button
        type="button"
        onClick={reset}
        className="mt-8 rounded-md bg-tidy px-5 py-2.5 text-sm font-medium text-ink transition-colors hover:bg-tidy/90"
      >
        Try again
      </button>
    </div>
  )
}
