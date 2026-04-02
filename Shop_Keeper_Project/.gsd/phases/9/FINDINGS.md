# Phase 9.1: Sync Engine Findings

## 1. Concurrent Sync Operations
**Finding:** `SyncService.syncAll()` lacks a concurrency lock (`_isSyncing` flag). If triggered rapidly (e.g., from multiple UI listeners or network reconnection events), it could cause simultaneous batch writes of the same unsynced records, leading to race conditions and wasted reads/writes.
**Recommendation:** Implement a boolean lock `_isSyncing` at the class scope.

## 2. Empty Queue Handling
**Finding:** The service iterates through all local boxes looking for unsynced items, but it does not cleanly short-circuit if there's nothing to do before attempting to process operations.
**Recommendation:** Add an early-exit check to return immediately if `unsyncedProducts.isEmpty && unsyncedSales.isEmpty && unsyncedExpenses.isEmpty`.

## 3. Large Batch Write Failures & Error Handling
**Finding:** The `batch.commit()` call is not wrapped in a `try-catch` block. If the network drops or Firestore quotas are reached, it will throw an unhandled exception, potentially crashing the caller. Additionally, the local records are correctly *not* marked as `isSynced` if an error occurs, but there's no retry delay mechanism.
**Recommendation:** Wrap the entire sync logic (specifically `batch.commit()`) in a `try-catch` block. Log the error. Ensure `_isSyncing` is reset in a `finally` block to prevent deadlocks.

## 4. Lack of Idempotency (Duplicate checks / Merge semantics)
**Finding:** Currently, the system uses a blind `batch.set(ref, data)` strategy which overwrites the entire document. If partial updates occurred elsewhere, they get wiped out.
**Recommendation:** Utilize `SetOptions(merge: true)` so that the set operation acts as an upsert that respects existing remote fields not present in the local map.

## 5. Conflict Resolution (updatedAt)
**Finding:** The current model purely uses "last device to sync wins" since `batch.set` is unconditional. True conflict resolution requires either offline transactions (not fully supported for complex merges) or server-side rules.
**Recommendation:** We will harden the base layer by ensuring atomic, idempotent batch writes first, setting the stage for `updatedAt` field comparisons in Phase 9.2 or a Cloud Function.
