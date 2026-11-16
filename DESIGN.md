# ENote interface system

**Primary target: Flutter.** The user clarified that UI/UX improvements belong in `lib/`. Native implementation and verification details are in `FLUTTER_UI_UX_AUDIT.md`; React is a separate reference implementation.

For Flutter, use Material 3 color roles and shared widgets in `lib/core/`, 48dp touch targets, growing text/button layouts, SafeArea/IME-aware native sheets, and bottom navigation on phones versus a persistent drawer on wide windows. Route branches retain state. Native screenshots must come from a Flutter emulator/device; browser captures are not native evidence. Current native localization remains Arabic; React's language switch is independent.

This pass refines the existing student workspace. The supplied ENote icon, bilingual content, lavender identity, and existing features remain the product's visual foundation.

- **Use scene:** students planning study, completing tasks, taking notes, and focusing, on phones and computers in light or dark environments.
- **Type:** Cairo when available, Tahoma for Arabic and Segoe UI for English as dependable offline fallbacks. Body and inputs 16px; secondary information 14px; compact navigation labels no smaller than 12px. Headings use a modest fixed scale.
- **Color:** deep violet for primary actions and current navigation; pale violet for selected surfaces; neutral canvas and panels. Secondary text must meet 4.5:1 contrast. Green means complete; red is reserved for destructive actions and errors.
- **Layout:** logical inline alignment for Arabic/RTL and English/LTR. Persistent side navigation on wide screens, a modal drawer and five-item bottom navigation on phones. No page-level horizontal scrolling. Weekly habit tables may scroll inside a labelled region.
- **Components:** 12–16px panel radius, a single subtle border, minimum 44px interactive targets, visible focus, and semantic links/forms/dialogs. Avoid promotional eyebrows, decorative emoji, colored side rails, and repeated entrance animations.
- **Content:** saved user content is never translated or rewritten. Date keys use local calendar days. Statistics derive from available task data and clearly name planned versus completed activity.
- **Behavior:** URLs reflect screens; refresh and Back preserve navigation. Deletions have an undo action. Notes open for full reading and editing. Forms identify invalid fields. Modal focus is contained and restored. Focus sessions survive navigation.
- **Verification:** Arabic and English, light and dark, 390px mobile, 820px intermediate, 1440px desktop, keyboard navigation, empty/long content, forms, undo, and production build. Browser emulation is not a substitute for testing physical devices or every assistive technology.
