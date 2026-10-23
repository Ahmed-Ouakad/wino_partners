# Project Rules & Guidelines

## 1. Clarification & Communication Over Independent Investigation
- **Ask Before Investigating:** If any requirement, data model, API contract, response format, or implementation detail is unclear or not found directly within this repository, **ask the user directly** rather than exploring external systems or investigating on your own.
- **No Autonomous Exploration:** Do not inspect background processes, system services, external repositories, or parent directories outside this workspace unless explicitly instructed by the user.
- **State Assumptions Clearly:** If multiple implementation paths or schemas are possible, present the options or ask for the schema instead of guessing or probing without permission.

## 2. Command Execution & Terminal Usage
- **Minimal & Deliberate Commands:** Do not run unsolicited exploratory scripts, queries, or PowerShell commands.
- **Respect User Scope:** Keep tool usage strictly focused on modifying, creating, and inspecting files within this repository.
- **No Background Probing:** Never query running ports, task managers, or process lists to infer information that can simply be provided by the user.

## 3. Architecture & Code Quality
- Follow Clean Architecture principles as already structured across existing features (`data`, `domain`, `presentation`).
- Adhere strictly to the established design system, color palette, and UI components.
- Use state management (BLoC) consistently across screens.

## 4. Project Context & Task Logging
- **Consult Context First:** At the beginning of each session or task, read `project_context.md` to understand the overall project goals and current progress.
- **Log Completed Work:** After completing any feature or task, append a clear summary of what was implemented to the **Progress Log** in `project_context.md`.
