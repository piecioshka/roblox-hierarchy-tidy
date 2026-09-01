import type { MetadataRoute } from 'next'
import { SITE_URL } from '@/lib/site'

// Required for `output: export` — the file is generated at build time.
export const dynamic = 'force-static'

// GitHub Pages serves project sites under /<repo>, so crawlers only read the
// robots.txt of piecioshka.github.io itself. This file still ships so the
// site is ready if it ever moves to its own domain.
export default function robots(): MetadataRoute.Robots {
  return {
    rules: { userAgent: '*', allow: '/' },
    sitemap: `${SITE_URL}sitemap.xml`,
  }
}
