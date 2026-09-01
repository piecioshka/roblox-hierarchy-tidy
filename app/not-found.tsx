import Link from 'next/link'

export default function NotFound() {
  return (
    <div className="flex min-h-screen flex-col items-center justify-center px-6 text-center">
      <p className="font-mono text-[11px] tracking-[0.22em] text-tidy uppercase">404</p>
      <h1 className="mt-5 font-display text-3xl font-semibold tracking-tight sm:text-4xl">
        Nothing here to tidy up.
      </h1>
      <p className="mt-4 max-w-md text-haze">
        This page does not exist — maybe it got grouped into a Folder somewhere else.
      </p>
      <Link
        href="/"
        className="mt-8 rounded-md bg-tidy px-5 py-2.5 text-sm font-medium text-ink transition-colors hover:bg-tidy/90"
      >
        Back to the homepage
      </Link>
    </div>
  )
}
