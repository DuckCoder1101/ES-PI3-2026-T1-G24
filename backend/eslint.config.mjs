import js from "@eslint/js";
import tseslint from "typescript-eslint";
import globals from "globals";

export default [
  // JavaScript
  js.configs.recommended,

  // TypeScript
  ...tseslint.configs.recommendedTypeChecked,

  {
    files: ["**/*.ts"],
    languageOptions: {
      parser: tseslint.parser,
      parserOptions: {
        project: "./tsconfig.json",
        tsconfigRootDir: import.meta.dirname,
      },
      globals: {
        ...globals.node,
      },
    },

    rules: {
      "no-unused-vars": "off",
      "@typescript-eslint/no-unused-vars": ["warn", { argsIgnorePattern: "^_" }],

      // Boas práticas
      "@typescript-eslint/consistent-type-imports": "error",
      "@typescript-eslint/explicit-function-return-type": "off",

      // Clean Architecture
      "max-depth": ["warn", 3],
      complexity: ["warn", 10],
    },
  },
];
