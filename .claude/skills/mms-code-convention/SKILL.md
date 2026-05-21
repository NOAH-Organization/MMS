---
name: mms-code-convention
description: Apply NOAH MMS code conventions to all code written in this session. Use when writing, reviewing, or refactoring TypeScript, React, Next.js, NestJS, or Docker code in the MMS project.
metadata: 
  version: 1.1.0
---

# MMS Code Conventions

Apply the NOAH MMS code conventions to all code you write in this session. These conventions are authoritative across every project in the MMS ecosystem.

---

## General (all languages)

- 4-space indentation; never nest more than 4 levels deep — JSX component trees are exempt from this limit
- Opening brace on the same line as the statement; closing brace on its own line unless followed by a continuation (`else`, `catch`, etc.)
- Each function does exactly one thing — decompose complex functions into smaller ones
- Avoid nested functions unless necessary
- Always apply the following logging conventions regardless of the logging library used:
  - Prefix every log message with `[functionName/filename]` followed by the timestamp in `DD-MM-YYYY HH:mm:ss` format — e.g. `[startApp/index.js] 20-05-2026 14:30:00`
  - Surround each function's log group with a separator line of 60 dashes (`-` × 60) at the start and end

---

## TypeScript

### File Naming

- Use `kebab-case` for all file and folder names (e.g., `user-service.ts`, `auth-guard.ts`)
- Use `PascalCase` for React component files, matching the component's export name (e.g., `UserCard.tsx`)
- Use `PascalCase` for class files, matching the class name

### Code Style

- `const` over `let`; only use `let` for variables that are reassigned
- Always end statements with `;`
- Single quotes `''` for all strings
- `<>` for type assertions (not `as`)
- `import` only — never `require`
- Always declare types for function parameters
- When declaring a constant with a custom type, define the interface first, then implement it in the constant
- **Exports:**
  - `export function` / `export class` when exporting directly
  - `const` declared first, exported at the bottom of the file
  - Single export per file → make it the default export
- **Import order:** `import type` before value imports → default imports before named → fewer imports before more imports
- **Function style:**
  - Named `function` declarations for all logic implementation
  - Arrow functions only for: IIFEs, wrapper functions with no logic, and callbacks inside reducers and function returns
- `void` + wrapper function when calling async functions without awaiting the result
- Prefer reducer functions (`.reduce()`, `.map()`, `.filter()`) over manual iteration
- Ternary operator for single-line conditional assignments and single-line return objects; `if` statements for multi-line conditional logic and multi-line return objects
- When fetching a file from a URL: use `Buffer` for server actions, `Blob` for browser downloads

### Logging

- Prefix log messages with an emoji that matches the intent of the message:
  - `✅` — success / completion
  - `❌` — error / failure
  - `⚠️` — warning / degraded state
  - `🔄` — processing / in-progress
  - `🚀` — startup / initialization
  - `💾` — database / storage operations
  - `📤` — outgoing requests / uploads
  - `📥` — incoming data / downloads

### JSDoc

Document all exported functions:

```typescript
/**
 * @desc [Detailed description of what this function does]
 * @param {Type} name - [What this input represents]
 * @returns {Type} name - [Description of the returned value]
 * @throws {ErrorType} [Conditions under which this error is raised]
 */
```

---

## React

- Function components (JSX) only — no class components
- JSX must return a single root element; wrap multiple elements in `<>` fragment or an array
- Embed expressions in JSX with `{}`; `{{}}` for inline objects (e.g. inline styles)
- Pass values via props; always declare prop types the same way as function parameters
- Define object props outside the component and import them
- Destructure `{}` when reading props
- Forward props to child elements with the spread operator `...`
- Use `children` prop for dynamic child rendering
- Render lists with `.reduce()` / `.map()`; always provide a `key`
- Treat `props`, `state`, `context`, hook return values, hook arguments, and values passed to JSX as read-only and immutable
- Update state only in response to user input
- Enable React Strict Mode and the ESLint React plugin
- **Purity & idempotency:**
  - Components and hooks must be pure and idempotent — same input always produces the same output; do not mutate variables that existed before the call
  - Avoid non-idempotent operations (random numbers, dates, network calls) during render
  - Local mutations and lazy initialization are fine; external side effects are not
- **Rules of Hooks:**
  - Call hooks only at the top level — never inside conditionals, loops, or nested functions; a hook must be called every time its parent function runs, unconditionally
  - Call hooks only from React function components or custom hooks
  - Never call component functions directly; never pass hooks as regular values
- Function components may contain at most one level of inner function nesting — do not define functions inside functions within a component body
- Side effects belong in event handlers, not during render; use effects only as a last resort
- Prefer named event handler functions over inline attribute arrow functions
- Prefer custom React components over raw HTML tags
- Use semantically meaningful HTML tags (`<section>`, `<article>`, etc.)

---

## Next.js

- App Router by default; React Strict Mode enabled
- Keep client components as deep in the import tree as possible
- Server components can be children of client components — do not `import` a server component inside a client component; pass its output via JSX from the parent instead
- Always use `<form>` and Server Actions to send data from client to backend; only invoke Server Actions from client components
- Client components only for user activity and interactivity
- Follow Next.js folder/file naming conventions
- Keep project files outside `app/`; `app/` contains routing files only (`page`, `layout`, `loading`, `not-found`, etc.)
- Use `<Link>` instead of `<a>`
- Set cookies server-side via the Next.js `cookies` API to prevent client-side tampering

---

## NestJS

- All business logic belongs in service files
- Module files handle only: imports, exports, and module declarations
- Controller files handle only: route and API endpoint definitions — no logic

---

## Docker

- Always add `.git`, `node_modules`, and `.venv` to `.dockerignore`
- Always use a `.env` file to supply environment variables — never hardcode values in `Dockerfile` or compose files

---

## Markdown (documentation files)

- Open every file with a `#` heading 1 as the title
- Place a bold `**Last revised:** DD/MM/YYYY hh:mm AM/PM` line immediately after the title
- Pad each table cell with a single space on each side (e.g., `| value |`, not `|value|`)
