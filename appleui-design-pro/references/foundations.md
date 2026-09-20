# Design foundations

Use for Apple screen/flow composition, in SwiftUI, Flutter, or an explicitly
requested web app. This carries forward Emil's Apple design foundations; technical
choices belong to the framework-specific references.

## Eight lenses for a decision

| Lens | Product decision |
| --- | --- |
| Purpose | Define the person's main task; remove competition while retaining useful context. |
| Agency | Keep back, cancel, undo, and interruption available where meaningful. |
| Responsibility | Explain data access at the moment of need; preserve drafts and clarify consequential actions. |
| Familiarity | Reuse platform patterns, recognizable symbols, consistent locations, and predictable behavior. |
| Flexibility | Adapt to window size, input, language, abilities, and expertise. |
| Simplicity | Make the common path clear; hiding all controls is not necessarily simple. |
| Craft | Fix text, alignment, state, responsiveness, and continuity before adding decoration. |
| Delight | Let calm, confidence, or playfulness emerge from coherent behavior. |

These lenses do not require confirmations, celebrations, or new preferences in every
feature. More UI earns its place only when it serves the current task.

## Screen structure

Identify primary information, primary action, secondary actions, navigation, and
temporary feedback. Define reading order before materials. A document list and a
floating document toolbar occupy different layers; only the toolbar is a natural
glass candidate. A rounded card is still content.

For a flow, specify entry → action → result → recovery or return. Every screen should
explain current location, available destinations, and an exit. Name destinations for
their content. Preserve tab history, scroll position, filters, selection, and drafts
when returning. Do not let a visual refresh recreate the entire navigation tree.

Group related controls by proximity and alignment. Separate groups more than items
inside a group. Put commands near what they affect and align direction with outcome.
Keep clear labels; useful spatial mapping does not replace accessible names. Use one
strongest action per local decision, retaining readable secondary controls.

## Navigation and presentation

| Situation | Starting choice | Preserve |
| --- | --- | --- |
| Peer destinations | System tabs / CupertinoTabScaffold | Per-tab history; tabs navigate rather than act as generic command buttons |
| Hierarchical drill-down | NavigationStack / CupertinoPageRoute | Back gesture, title, path and selection |
| Wide sidebar/content/detail | NavigationSplitView / adaptive Flutter composition | Selection during collapse; resizable windows |
| Focused temporary task | System sheet / supported Cupertino sheet route | Cancel/done, detents where available, keyboard, draft ownership |
| Choice in context | Menu, popover, action sheet | Anchor, dismissal and focus return |
| Parallel work | Sidebar/inspector | Continued access to main content without unnecessary scrim |

System presentation behavior wins over a homemade transition. Custom transitions
should preserve coherent origin and return path. A centered modal can be independent
of its trigger; not everything must grow from a button. Modal scrims signal a blocked
background; nonmodal panels should not silently block the rest of the interface.

## Feedback and real states

Distinguish status, completion, warning, and error. Validate near the relevant field
after useful interaction; avoid noisy errors before typing. On failure, retain input
and provide a specific next action. Explain disabled actions when their cause is not
obvious. Progress tracks real work rather than an invented timer.

Visual press feedback starts immediately; commit follows the control's successful
activation. A loading indicator should not erase context or falsely imply completion.
Optimistic updates need a rollback and understandable failure state. Avoid animating
every refresh of a frequently used command.

## Coherent visual language

Type conveys information priority, materials convey surface role, and motion explains
relationships and change. Decide them together. A sidebar, floating command, and
reading surface should not receive identical effects merely because all are rounded.
Emphasize through weight, grouping, spacing, and semantic color before extra shadows
or layers. Use color selectively for primary actions or meaningful status.

Prototype the hardest interaction in context. Include populated, empty, long-content,
failure, and interruption cases when relevant. Slow playback diagnoses jumps; normal
use determines perceived speed. Record evidence from the current product rather than
declaring a design inaccessible solely because it uses transparency.
