# NOAH Manga Management System (NOAH MMS) — Code Conventions

**Last revised:** 08/05/2026 11:33 AM

## General (for all programming languages)

- Use 4-space indentation
- Advoid nesting over 4 levels of indentation
- Use the framework logging configurations; If there is none, use the custom logging styles:
  - Annouce the current process function and file at the begining of the logging sentences, example `[startApp/index.js]`
  - Use a separator - 60 repeats of `-` symbol - for logging at the start and the end of functions
- Should avoid nesting function unless necessary
- Always put the opening brace last on the line and the closing brace is empty on a line of its own unless it is followed by a continuation of the same statement
- Function should be precise and only do one thing - try to decomposite them into smaller function if it becomes too complex

## Markdown

- Always open a file with a heading 1 (`#`) as the title
- Space to the right and left for table column style "compact"
- Place a bold **Last revised:** line immediately after the title, formatted as `DD/MM/YYYY hh:mm AM/PM`
  - Example: `**Last revised:** 25/04/2026 09:53 AM`

## TypeScript

- Use `<>` for type assertions
- Prefer `const` over `let`; only use `let` for variables whose value is reassigned
- Always end a statement with `;`
- Exports:
  - Use `export function` or `export class` when exporting a function or class directly
  - Declare constants with `const`, then export them at the bottom of the file
  - If a file contains only one function, class, or constant, always make it the default export
- Wrap strings in single quotes `''`
- Always declare types for function parameters
- When declaring a constant with a custom type, define the interface first, then implement it in the constant
- Always use `import` to import modules; never use `require`
- Prefix log messages with an emoji that matches the message's intent
- Prefer named `function` declarations over arrow functions for logic implementation
- Use arrow functions only for: IIFEs, wrapper functions that contain no logic, and callbacks inside reducers and function return
- When calling an async function without awaiting its result, use `void` and wrap the call in a wrapper function
- Order import statements as follows: `import type` before value imports → default imports before named imports → fewer imports before more imports
- Prefer reducer functions over manual iteration
- Use the ternary operator for single-line conditional assignments and single-line return objects; use `if` statements for multi-line conditional logic and multi-line return objects
- When fetching file from an URL: use Buffer for server actions, use blob for browser download
- Document functions using the following JSDoc template:

```javascript
/**
 * @desc [Detailed description of the function's purpose, what it does]
 * @param {Type} name - [What this input represents]
 * @param {Type} name - [Repeat for each parameter]
 * @returns {Type} name - [Description of the returned value]
 * @throws {ErrorType} [Conditions under which this error is raised]
 */
```

### React

- Use function component (JSX) by default instead of class component
- JSX must always return a single root element; use `<>` (fragment) or an element array to wrap multiple elements
- Use curly braces `{}` to embed JavaScript expressions inside JSX
- Double curly braces `{{}}` denote a JavaScript object inside JSX, commonly used for inline CSS styles
- Use props to pass values into components; always declare prop types the same way as function parameters
- For object props, define the object outside the component and import it
- Use destructuring `{}` when reading props
- Forward props to child elements using the spread operator `...`
- Use the `children` prop to pass JSX into a component for dynamic rendering of child elements
- Use a reducer (`.reduce()`, `.map()`) when rendering a list of components; always provide a `key`
- Keep component and hook functions pure: do not mutate variables or objects that existed before the function was called, and always return the same output for the same input
- Treat `props`, `state`, and `context` as read-only
- Update state in response to user input
- Enable React Strict Mode and the ESLint React plugin
- Follow the Rules of React strictly:
  - Components and Hooks must be idempotent
    - Avoid using non-idempotent functions during render
  - Side effects must run outside of render
    - Use event handlers to handle side effects
    - When mutations are fine: local mutations, lazy initialization
  - Props and state are immutable
  - Return values and arguments to hooks are immutable
  - Values are immutable after being passed to JSX
- Let React call components and hooks:
  - Never call component functions directly
  - Never pass hooks as regular values
- Follow the Rules of Hooks strictly:
  - Only call hooks at the top level
  - Only call hooks from React function components or custom hooks
  - Never pass it around as a regular value
- Prefer expressing logic through rendering; use side effects only as a last resort
- Instead of mutating a Hook dynamically, create a static version of the Hook with the desired functionality
- Always inline the call of the Hook into that component and handle any logic in there instead of dynamically used it in a component
- Prefer defining a function for event handlers over inline attribute arrow function
- Prefer custom React components over raw HTML tags
- Use semantically meaningful HTML tags (e.g., `<section>` for page sections, `<article>` for self-contained content)

### Next.js

- Use the App Router by default
- Enable React Strict Mode by default
- Keep client components as deep in import tree as possible. NOTE: a server component can still be a child of a client server - however, avoid import the server component inside client one, instead nest JSX components directly from parent component
- Always use `<form>` tag for getting data from client to write into backend. Use server action only for client components in client->server data direction.
- Only use client for user activity and interactivity
- Follow Next.js folder/file naming conventions
- Keep project files outside the app directotry, only keep routing files (page, layout, loading, not-found, ...) inside it (purely for routing purposes).
- Prefer Next.js `<Link>` component instead of HTML default `<a>`

### NestJS

- All logic belongs in service files; module files handle only imports, exports, and module declarations; controller files handle only route/API definitions

## Docker

- Always add `.git`, `node_modules`, and `.venv` to `.dockerignore`
- Always use a `.env` file to supply environment variables in `Dockerfile` and compose files (`docker-compose.yml`, `compose.yaml`)
