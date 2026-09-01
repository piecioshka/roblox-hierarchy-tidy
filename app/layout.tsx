import type { Metadata, Viewport } from 'next'
import { Bricolage_Grotesque, IBM_Plex_Mono, IBM_Plex_Sans } from 'next/font/google'
import { SITE_URL } from '@/lib/site'
import './globals.css'

const display = Bricolage_Grotesque({
  subsets: ['latin'],
  variable: '--font-display',
})

const body = IBM_Plex_Sans({
  subsets: ['latin'],
  weight: ['400', '500', '600'],
  variable: '--font-body',
})

const mono = IBM_Plex_Mono({
  subsets: ['latin'],
  weight: ['400', '500'],
  variable: '--font-mono',
})

// Next applies basePath to bundled assets but not to icon URLs in metadata,
// which would 404 under the /<repo> prefix on GitHub Pages.
const asset = (path: string) => `${process.env.NEXT_PUBLIC_BASE_PATH ?? ''}${path}`

export const metadata: Metadata = {
  metadataBase: new URL(SITE_URL),
  title: 'Hierarchy Tidy — a Roblox Studio plugin for a messy Explorer',
  description:
    'Find duplicates, group by class, number names and delete empty folders in the Roblox Studio Explorer. Every change undoes with Ctrl+Z.',
  alternates: {
    canonical: '/',
  },
  icons: {
    icon: [
      // Classic .ico fallback — Google Search ignores SVG-only favicons.
      {
        url: asset('/favicon.ico'),
        sizes: '32x32',
      },
      {
        url: asset('/icon-light-32x32.png'),
        media: '(prefers-color-scheme: light)',
      },
      {
        url: asset('/icon-dark-32x32.png'),
        media: '(prefers-color-scheme: dark)',
      },
      {
        url: asset('/icon.svg'),
        type: 'image/svg+xml',
      },
    ],
    apple: asset('/apple-icon.png'),
  },
  openGraph: {
    type: 'website',
    title: 'Hierarchy Tidy — a Roblox Studio plugin for a messy Explorer',
    description:
      'Find duplicates, group by class, number names and delete empty folders in the Roblox Studio Explorer.',
  },
}

export const viewport: Viewport = {
  colorScheme: 'dark',
  themeColor: '#14161b',
}

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode
}>) {
  return (
    <html lang="en" className={`${display.variable} ${body.variable} ${mono.variable}`}>
      <body className="antialiased">{children}</body>
    </html>
  )
}
