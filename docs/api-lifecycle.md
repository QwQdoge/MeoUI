# MeoUI API lifecycle

MeoUI is a shared UI library. Public QML may outlive the product surface that first introduced it, so new and old patterns must be classified explicitly instead of being left side-by-side with equal status.

## Status classes

### Current
Recommended for new product work. Current components are documented in Showcase/catalog coverage and follow current Material 3 Expressive guidance.

### Compatibility / deprecated
Kept to avoid breaking existing consumers. Deprecated APIs remain source-compatible for a transition window but must not be selected for new feature work when a Current replacement exists.

### Experimental
Public or semi-public work that is still being validated. Experimental components may change without the same migration guarantees as Current APIs and must be clearly labelled in docs/Showcase.

### Internal
Implementation details not intended as product-facing API.

## Initial classification

### Current
- `MeoDockedToolbar.qml`: current docked action-surface pattern for new work.
- `MeoWidget.qml`: current platform-neutral widget contract.
- `MeoWidgetSheet.qml`: current widget catalogue/browser pattern.
- established Material 3 Expressive controls, semantic tokens, motion and responsive layout primitives that are covered by the current Showcase.

### Deprecated compatibility
- `MeoBottomAppBar.qml`: legacy baseline retained for compatibility. New work should use `MeoDockedToolbar` when the surface is a docked action toolbar. Do not mechanically replace it when a consumer actually needs navigation rather than actions.

The migration notation is:

`MeoBottomAppBar -> MeoDockedToolbar` for docked action surfaces.

This is a product/API recommendation, not permission to delete the old type.

## Deprecation rules

A deprecation must include:

1. the replacement or explicit statement that no direct replacement exists;
2. a reason based on product/API semantics, not only visual preference;
3. a migration note when properties/signals/behavior differ;
4. Showcase/catalog labelling;
5. no silent removal while known maintained consumers still depend on it.

Deprecated components may receive correctness, accessibility and compatibility fixes. They should not receive new product-specific features that belong in the replacement.

## Experimental rules

Experimental APIs must be clearly marked in their source documentation and Showcase metadata. A feature becomes Current only after its public contract, adaptive behavior, accessibility and validation path are stable enough for maintained consumers.

## Removal rules

Removal requires a dedicated cleanup change that verifies repository consumers and known first-party consumers have migrated. Do not remove a type as incidental work during unrelated UI changes.

## Ownership

Reusable lifecycle/migration rules live here. Plasma/KWin or application-specific migration belongs in the owning repository; MeoUI must not keep a legacy component solely because an owning application refused to migrate without documenting that dependency.
