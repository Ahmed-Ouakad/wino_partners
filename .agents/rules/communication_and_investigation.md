# Communication & Investigation Rules

## 1. Ask Before Investigating
- If any requirement, API contract, response schema, or business rule is missing or unfamiliar, **ask the user directly**.
- Do **not** conduct unauthorized or deep investigative steps (e.g., inspecting external processes, scanning background services, or exploring external directories outside the workspace).

## 2. Command Execution Discipline
- Avoid exploratory terminal or PowerShell commands.
- Only run commands that are strictly necessary and directly related to the user's explicit task within this workspace.

## 3. Scope Boundaries
- Focus strictly on the active project repository (`wino_partners`).
- Confirm assumptions with the user before making major design decisions.

## 4. Project Context & Task Logging
- Always consult `project_context.md` at the beginning of conversations to align with the project goals and status.
- Every time a task or feature is finished, append a summary of completed changes to the **Progress Log** in `project_context.md`.

