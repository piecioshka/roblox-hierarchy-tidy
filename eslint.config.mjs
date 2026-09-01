import js from '@eslint/js'
import prettier from 'eslint-config-prettier'
import tseslint from 'typescript-eslint'

export default tseslint.config(
  { ignores: ['.next/', 'out/', 'node_modules/', 'next-env.d.ts', 'tmp/'] },
  js.configs.recommended,
  ...tseslint.configs.recommended,
  {
    files: ['**/*.mjs'],
    languageOptions: {
      globals: { process: 'readonly' },
    },
  },
  prettier,
)
