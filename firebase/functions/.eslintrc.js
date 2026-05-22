module.exports = {
  root: true,
  env: {
    es6: true,
    node: true,
  },
  extends: [
    "eslint:recommended",
    "plugin:import/errors",
    "plugin:import/warnings",
    "plugin:import/typescript",
    "google",
    "plugin:@typescript-eslint/recommended",
    "prettier", // Garante que o Prettier tenha a última palavra
  ],
  parser: "@typescript-eslint/parser",
  parserOptions: {
    tsconfigRootDir: __dirname,
    project: ["tsconfig.json", "tsconfig.dev.json"],
    sourceType: "module",
  },
  ignorePatterns: ["/lib/**/*", "/generated/**/*"],
  plugins: ["@typescript-eslint", "import"],
  rules: {
    // 1. Mata os erros de aspas de uma vez por todas
    quotes: "off",

    // 2. Resolve o erro de "non-null assertion" (!.) que apareceu no log
    "@typescript-eslint/no-non-null-assertion": "off",

    // 3. Desliga as regras de indentação e formatação da Google que conflitam
    indent: "off",
    "object-curly-spacing": "off",
    "operator-linebreak": "off",
    "max-len": "off",

    // 4. Resolve problemas de importação chatos
    "import/no-unresolved": 0,
    "import/named": 0,
    "import/namespace": 0, // Mata o erro "invalid interface loaded as resolver"
    "import/default": 0,
    "import/no-duplicates": 0,
  },
};
