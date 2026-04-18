# Personal Claude defaults

## Stack defaults
- Primary language: TypeScript
- Secondary language: Python
- Growth language: Go
- JS package manager: pnpm
- JS runtime default: Node
- Python toolchain: uv

## Frontend posture
- Avoid React for new projects unless explicitly required.
- Prefer Web Components, Lit, Solid, or minimal server-rendered HTML.
- Prefer platform primitives over framework abstractions.
- Keep client state explicit and small.
- Use discriminated unions / typed state models where helpful.
- Keep effects at the edges.

## LLM engineering defaults
- Keep frontend thin and backend typed.
- Start with provider SDKs before adding orchestration/agent frameworks.
- Prefer explicit data contracts and typed boundaries.
- Minimize dependencies and avoid unnecessary abstractions.
- Generate code that is easy to run, inspect, and modify.

## Language selection rules
- Use TypeScript for product-facing apps, APIs, and UI.
- Use Python for evals, scripts, experiments, and data workflows.
- Use Go for infra services, workers, ingestion pipelines, and CLIs.

## Agent behavior
- Do not introduce React or large frontend frameworks unless already required.
- Prefer simple, direct implementations over abstraction-heavy designs.
- Avoid adding frameworks before there is clear evidence they are needed.
- Keep solutions aligned with the repo's existing patterns.

## Learning priorities
- Prefer understanding the runtime and systems my code actually executes on
- Study abstractions from the top down, not bottom up
- Only dive into lower-level details (OS, compilers, hardware) when they explain real problems
- Prioritize networking, runtime behavior, and system performance over low-level implementation details
- Avoid deep dives into low-leverage topics unless explicitly needed
