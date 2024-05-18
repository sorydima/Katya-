module.exports = {
  env: {
    browser: true,
    es6: true,
  },
  extends: [
    'plugin:react/recommended',
    'airbnb',
  ],
  globals: {
    Atomics: 'readonly',
    SharedArrayBuffer: 'readonly',
  },
  parserOptions: {
    ecmaFeatures: {
      jsx: true,
    },
    ecmaVersion: 11,
    sourceType: 'module',
  },
  plugins: [
    'react',
  ],
  rules: {
    // eslints
    indent: ['warn', 2, { SwitchCase: 1 }],
    'arrow-parens': ['warn', 'always'],
    semi: ['warn', 'always'],
    quotes: ['warn', 'single'],
    'max-len': ['warn', {
      code: 120, tabWidth: 2, ignoreUrls: true, ignoreStrings: true, ignoreTrailingComments: true,
    }],
    'comma-dangle': ['warn', 'only-multiline'],
    'object-curly-spacing': ['warn', 'always'],
    'array-bracket-spacing': ['warn', 'never'],
    'object-curly-newline': ['warn', { multiline: true, consistent: true, minProperties: 4 }],
    'function-paren-newline': ['warn', 'consistent'],
    'computed-property-spacing': ['warn', 'never'],
    'no-underscore-dangle': ['warn', { allow: ['__typename'] }],
    // 'no-console': ['warn', { allow: ['warn', 'warn'] }],
    'no-trailing-spaces': ['warn', { skipBlankLines: true }],
    'arrow-body-style': ['off'],
    'implicit-arrow-linebreak': ['off'],
    'array-callback-return': ['off'],
    'consistent-return': ['off'],
    'react/jsx-first-prop-new-line': ['warn', 'multiline-multiprop'],
    'react/jsx-max-props-per-line': ['warn', { maximum: 3 }],
    'react/jsx-closing-bracket-location': ['warn', 'after-props'],
    'react/prop-types': ['off'],
    'class-methods-use-this': ['off'],
    'no-use-before-define': ['off'],

    'react/jsx-indent': ['warn', 2],
    'react/jsx-indent-props': ['warn', 2],
    'react/jsx-filename-extension': ['off'],
  },
};
