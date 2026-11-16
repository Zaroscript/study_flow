# ENote UI/UX skills

Selected on 2026-11-15. The user clarified that the primary target is the native Flutter app under `lib/`, not the separate React/Vite reference.
Skills are installed in the user's Codex skills directory, not bundled into the app.
Installation verified: all four contain `SKILL.md`; UI UX Pro Max's local search returned a matching keyboard-focus guideline. Impeccable's Windows launcher and references are present; its engine has not been executed as part of installation.

| Skill | Upstream source | Use in ENote |
| --- | --- | --- |
| `impeccable` | https://github.com/pbakaus/impeccable | Visual direction, critique, polish, responsive adaptation, UX copy, and edge cases. |
| `ui-ux-pro-max` | https://github.com/nextlevelbuilder/ui-ux-pro-max-skill | Searchable guidance for design systems, typography, palettes, charts, accessibility, RTL, React, and Flutter. |
| `web-design-guidelines` | https://github.com/vercel-labs/agent-skills/tree/main/skills/web-design-guidelines | Review accessibility, focus, forms, interaction, and web interface quality. |
| `vercel-react-best-practices` | https://github.com/vercel-labs/agent-skills/tree/main/skills/react-best-practices | React rendering and bundle performance as interfaces evolve. Installed directory: `react-best-practices`. |

## Suggested requests

- “Use Impeccable to critique ENote's dashboard, then polish the agreed issues.”
- “Use UI UX Pro Max to review the typography and color system for Arabic and English.”
- “Use web-design-guidelines to review the forms and dialogs for accessibility.”
- “Use vercel-react-best-practices to review UI rendering and bundle size.”

## Project context

- Product name: **ENote**. Preserve the supplied icon at `public/assets/enote-icon.png`.
- Primary native entry points: `lib/main.dart`, `lib/core/theme/`, `lib/core/widgets/`, `lib/core/router/`, and `lib/features/`.
- Separate web reference: `main.tsx`, `studyflow.tsx`, `redesign.css`, and `i18n.ts`. Its English support and screenshots do not prove native functionality.
- Use Impeccable native/Android guidance and UI UX Pro Max's Flutter stack guidance for native changes. React performance rules and web audits apply only to the web reference.
- Validate both Arabic/RTL and English/LTR, mobile and desktop, and light/dark themes.
- Keep user-authored tasks, notes, names, and other saved content intact.
- Prioritize readable text, accessible contrast, keyboard interaction, touch targets, and clear task flows.
- Baseline screenshots: `screenshots/2026-11-15/`; redesign: `screenshots/redesign/`; English: `screenshots/english/`.
- Follow the selected skill's installed `SKILL.md` and references when actually invoking it. Installation alone does not start a redesign, enable hooks, or publish the app.
