# State, rendering, and performance

This consolidates the UI-relevant Swift/Flutter advice in Emil and ECC. It does not
require a new architecture, state library, concurrency setting, or backend rewrite.

## SwiftUI

Use local `@State` for owned ephemeral values, `@Binding` for parent-owned editable
values, and Observation where the deployment target supports it. Owned `@Observable`
models can live in `@State`; use `@Bindable` when projections are needed. Inject
shared dependencies through the established environment. Preserve existing
ObservableObject patterns where compatibility or project conventions justify them.

Prefer enums for mutually exclusive loading/loaded/error phases. Do not silently
convert a fetch failure to an empty list: empty and failed require different recovery.
Preserve useful stale data during refresh and use request identity/cancellation to
avoid old results overwriting new ones. Place UI-facing mutations on the proper actor;
inspect Swift language mode and isolation settings instead of assuming every async
function leaves the main actor or rewriting project-wide defaults.

Use `.task(id:)` for view-lifetime work when appropriate. Cancellation is cooperative:
avoid publishing results after cancellation. Keep synchronous UI feedback on the
input path and move expensive work out of body/gesture callbacks. Do not use detached
tasks or unchecked Sendable to silence isolation errors. Pure value data is preferable
across isolation boundaries; bindings/views/styles remain in the UI domain.

Stable IDs preserve identity in changing lists; indices are fine only for truly
fixed positional items. Keep state reads near their consumers and use lazy containers
for substantial collections. A view's Equatable conformance is not proof that rendering
will be skipped automatically; use the supported equatable wrapper when justified,
and include all relevant inputs. Profile before adding custom caching or erasure.

## Flutter

Keep state with its owner. Preserve the project's state-management model; use
immutable emitted state for immutable-state libraries and the correct reactive
mutation rules for reactive libraries. Avoid shared mutable references that bypass
notifications. For purely local UI, setState or ValueNotifier may suffice.

Use stable keys for reorderable stateful items. Reusable widget classes and const
children help localize rebuilds; extracting a method is not itself a correctness bug.
Don't perform I/O, expensive image processing, or shader compilation in build.
Cache loaded FragmentProgram, create/dispose each mutable shader with its owner,
and don't change the same shader instance for two simultaneous surfaces.

Dispose owned animation/text/scroll controllers, subscriptions, timers, and images.
After await, check lifetime before using context or setState; also prevent stale data
from overwriting newer state. Use lazy lists/slivers, appropriately decoded image
sizes, and targeted rebuilds. Don't add RepaintBoundary everywhere without measuring.

## Optional on-device intelligence UI

For optional Apple Intelligence UI, check actual model/device availability and show
a useful unavailable state. Treat streamed partial results as partial, preserve
stable IDs while they update, distinguish failure from empty output, and allow
cancellation. Do not label a partial response complete. Keep UI scheduling and
rendering separate from model work; no model dependency is required for ordinary UI.

## Glass and frame budget

Keep effects bounded. Glass renders background as well as foreground, so many small
blur/mask/shadow operations can still be expensive. Native GlassEffectContainer groups
related native glass; Flutter BackdropGroup shares filter input for compatible
non-overlapping effects but does not morph shapes. Overlapping backdrop filters must
not share a key if that changes the intended result. Check current APIs before use.

For custom optical maps, cache geometry-only fields and allocations; recompute only
the changed region/parameters. CPU per-pixel loops are suitable for small/static maps,
not automatically for a full-screen animation. Prefer GPU sampling for continuous
Flutter refraction when supported. Shader bounds, pixel density, source texture
lifetime, and color/alpha conventions are part of correctness.

Measure realistic populated UI, scroll and drag simultaneously, and first use of an
effect. Inspect main/UI-thread work and raster/GPU time separately. A GPU-backed
property can still be expensive to composite. Flutter DevTools profile mode and
Apple Instruments provide evidence; screenshots and static analysis do not prove FPS.
