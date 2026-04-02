---
phase: 9
plan: 1
wave: 1
---

# Plan 9.1: Firestore Sync Reliability Audit

## Objective
Audit the current `SyncService` and `Hive`-to-`Firestore` integration to identify potential race conditions, duplicate writes, and sync failures. This is the foundation for a production-ready, multi-terminal Cloud Sync engine.

## Context
- .gsd/SPEC.md
- lib/services/sync_service.dart
- lib/database/hive_manager.dart
- lib/features/billing/data/repositories/billing_repository_impl.dart

## Tasks

<task type="auto">
  <name>Sync Engine Code Review</name>
  <files>lib/services/sync_service.dart</files>
  <action>
    Review the synchronization logic for:
    1. Lack of idempotency in sales records (duplicate check).
    2. Missing retry logic for transient Firestore failures.
    3. Update time conflict resolution (updatedAt field usage).
  </action>
  <verify>Documentation of findings in .gsd/phases/9/FINDINGS.md</verify>
  <done>Findings documented with specific code locations.</done>
</task>

<task type="auto">
  <name>Stress Test Connectivity Edge Cases</name>
  <files>lib/services/sync_service.dart</files>
  <action>
    Implement defensive checks for:
    - Empty local queues during sync triggers.
    - Concurrent sync calls (prevent multiple simultaneous sync operations).
    - Large batch write failures.
  </action>
  <verify>flutter analyze passes</verify>
  <done>SyncService hardened against basic race conditions and state inconsistencies.</done>
</task>

## Success Criteria
- [ ] Identification of at least 3 sync-related improvements.
- [ ] Baseline hardening of SyncService completed.
- [ ] Verified `flutter analyze` — 0 errors.
