---
phase: 9
plan: 3
wave: 1
---

# Plan 9.3: Manual Conflict Resolution Dialog

## Objective
Create a UI dialog for manual conflict resolution when local and remote data diverge. This gives users control over data integrity during multi-device sync operations.

## Context
- .gsd/SPEC.md
- lib/services/sync_service.dart
- lib/core/widgets/ (standard widget location)

## Tasks

<task type="auto">
  <name>Create ConflictResolutionDialog</name>
  <files>lib/core/widgets/conflict_resolution_dialog.dart</files>
  <action>
    Create a dialog widget that shows:
    1. Document type and ID
    2. Side-by-side comparison of local vs remote values
    3. Three options: Keep Local, Keep Remote, Merge (if applicable)
    4. Timestamp display for both versions
  </action>
  <verify>Dialog renders correctly with mock data</verify>
  <done>ConflictResolutionDialog created with Royal Obsidian styling</done>
</task>

<task type="auto">
  <name>Add Conflict Detection Service</name>
  <files>lib/services/conflict_detection_service.dart</files>
  <action>
    Create a service that:
    1. Compares local updatedAt with remote updatedAt
    2. Detects when both sides have modified the same document
    3. Queues conflicts for manual resolution
  </action>
  <verify>Service correctly identifies conflicts</verify>
  <done>Conflict detection implemented in SyncService</done>
</task>

<task type="auto">
  <name>Integrate Conflict Dialog in SyncService</name>
  <files>lib/services/sync_service.dart</files>
  <action>
    Modify SyncService to:
    1. Call conflict detection before batch writes
    2. Present dialog for unresolved conflicts
    3. Apply user-selected resolution
  </action>
  <verify>flutter analyze passes</verify>
  <done>Dialog integration complete</done>
</task>

## Success Criteria
- [ ] ConflictResolutionDialog with side-by-side comparison
- [ ] Conflict detection in sync operations
- [ ] User can choose local/remote resolution
- [ ] Verified `flutter analyze` — 0 errors.
