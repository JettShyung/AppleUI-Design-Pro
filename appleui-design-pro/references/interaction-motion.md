# Interaction and fluid motion

This preserves the full interaction model in Emil's Apple skill, supplemented by
the liquid-glass drag implementation and native/Flutter mappings.

## Immediate response and semantics

Show press feedback on down; commit only through successful activation on release
or the control's keyboard/accessibility action. Support cancel by moving away and
platform re-entry behavior. A subtle press scale/color change is a starting option,
not an instruction to rescale every native control. Never duplicate native feedback
with an extra gesture handler that commits twice.

Continuous controls track input while it happens. Do not add a debounce, spring lag,
or asynchronous task between a drag update and its position. A decorative highlight
may ease toward a pointer; the object being dragged should remain under it.

## Gesture lifecycle

Track the initial grab offset. Coordinate scroll and drag recognizers before owning
the gesture; a small movement threshold helps determine intent. Ignore extra pointers
when the operation is single-touch. Handle cancellation, view removal, lost focus,
and interrupted presentation; leave state consistent in every exit path.

SwiftUI: prefer built-in controls and presentations, then `DragGesture` with explicit
transient/committed state. Flutter: let recognizers participate in the gesture arena;
do not use a global listener to preempt scroll. Web: Pointer Events, pointer capture,
`pointercancel` and `lostpointercapture`, and an appropriate `touch-action`.

## Interruptible settling

Motion starts from the currently displayed value and its velocity, not an old target.
Retarget instead of locking input until completion. A mid-flight re-grab should not
jump to the logical destination. Use system gesture-driven transitions where possible;
a custom implementation must explicitly manage the current presentation state.

For spring APIs distinguish damping ratio, physical damping coefficient, response,
settling duration, and velocity units. A practical initial native spring is response
around 0.3–0.4 seconds with damping fraction near 1; a little overshoot may suit an
actual flick. These are tuning defaults from source examples, not universal Apple
shipping values. Do not use identical numbers for unrelated parameterizations.

If an API needs normalized initial velocity, divide by remaining distance only when
nonzero. Clamp unstable near-zero cases or finish without a spring. Use independent
x/y velocity for two-axis motion. Flutter `SpringSimulation` uses position units per
second: normalize pixels-per-second when animating a 0–1 controller.

## Momentum and boundaries

Use projected destination, travel, direction, and the available snap targets together.
A release near the top with downward velocity should not accidentally dismiss upward.
Prefer SwiftUI predicted end translation or platform scroll physics; in custom
scroll-like projection, a common exponential model is:

```
projected = current + (velocityPerSecond / 1000) * d / (1 - d)
```

`0 < d < 1`; values such as 0.998 are contextual examples. Don't mix milliseconds
with seconds or import a threshold such as 0.11 without its units and direction.
At boundaries, a useful signed resistance is:

```
resisted = overshoot * extent * c / (extent + c * abs(overshoot))
```

Use positive extent and coefficient, handle a zero-sized view, and preserve sign.
This signals a limit while maintaining response. Never allow the only exit or
essential action to become unreachable after a drag or resize.

## Timing, direction, and continuity

Use motion for feedback, state, spatial relationships, or explanation. Reduce or
remove decorative transitions on heavily repeated actions, including keyboard flows,
while retaining focus and state feedback. Do not delay actions for a flourish.

Small press feedback often settles in roughly 100–160 ms; transient UI can start
around 150–300 ms and be tuned in context. Springs aren't fixed-duration tweens.
Avoid slow starts that delay visible response. Reversible paths should be coherent,
but system navigation and centered modals do not require an invented origin rule.
Hint toward the destination during intermediate motion.

CSS transitions can retarget from their current interpolated value; they do not by
themselves guarantee gesture-velocity continuity. Use a suitable controller/spring
when velocity handoff matters. Native SwiftUI animations likewise do not grant access
to every presentation value; prefer native controls over custom animation machinery.

## Haptics and sound

Feedback should have a clear cause, coincide with the meaningful state event, and
serve a purpose. Use selection/snap/commit/success/error feedback sparingly. Avoid
duplicate vibration when the control already supplies it. SwiftUI can use
`.sensoryFeedback` where available; Flutter has `HapticFeedback` with platform-specific
behavior. Do not promise exact same-frame synchronization across asynchronous bridges.
Do not put sensitive meaning exclusively in sound, vibration, motion, or color.

## Frame quality and reduced motion

Use the framework's display-synchronized animation rather than timers that fight the
render loop. Minimize layout/paint work per frame. Velocity cues such as stretch or
blur are optional for appropriate fast decorative motion; they are not a requirement
to blur controls or text. Avoid slow large-area oscillations and unnecessary parallax.

Reduce Motion should replace large movement and elastic effects with a brief fade,
state change, or static endpoint, retaining comprehension. Check reversal, rapid
repeat, dismissal during loading, rotation/resizing mid-drag, and loss of input.
