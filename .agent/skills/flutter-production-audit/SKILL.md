---
name: flutter-production-audit
description: Comprehensive production release auditor and verification engine for Flutter applications. Evaluates security boundaries, offline persistence, memory leaks, store readiness, Android/iOS permissions, lifecycle flushes, and produces a prioritized PRODUCTION-AUDIT-REPORT.md.
---

# Flutter Production Audit Agent Skill

Evaluates Flutter applications systematically across 6 critical domains before Google Play & App Store submission.

## Core Audit Laws
1. **No Assumptions, Direct Inspection**: Never assume `pubspec.yaml`, `AndroidManifest.xml`, or controllers are correct; parse and verify them directly.
2. **Offline-First & Data Safety**: Ensure zero secret leakage, strictly validated local storage (SQLite/Drift/SecureStorage), and unhandled error containment.
3. **Evidence-Driven**: Every finding must cite exact file paths and line numbers with actionable remediation steps.

## Checklist Domains
1. **Security & Secrets (P0)**: Hardcoded API keys, Dart code obfuscation flags, storage safety, and backend boundary checks.
2. **Platform Manifests & Store Policy (P1)**: Android 14+ `targetSdk`, permission rationale, privacy manifests.
3. **Performance & Memory (P1)**: Controller disposal, `const` constructor usage, list virtualization, image asset caching.
4. **Resilience & State (P1)**: Offline fallback, Riverpod error containment, app lifecycle observer flushes.
5. **Error Net & Telemetry (P2)**: `FlutterError.onError`, `PlatformDispatcher.onError`, unhandled async catchers.
6. **Store Shipping Polish (P3)**: Launcher icons, notification icons, bilingual localization (Arabic RTL & English LTR).
