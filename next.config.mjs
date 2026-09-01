/** @type {import('next').NextConfig} */

// On GitHub Pages the site lives under /<repo>, so assets need that prefix.
// The Pages workflow sets NEXT_PUBLIC_BASE_PATH; locally it stays empty.
const basePath = process.env.NEXT_PUBLIC_BASE_PATH ?? ''

const nextConfig = {
  output: 'export',
  basePath,
  trailingSlash: true,
  images: {
    unoptimized: true,
  },
}

export default nextConfig
