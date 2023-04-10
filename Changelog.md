# Changelog

## 1.0.0 (Upcoming)

### Added

- Added documentation for the Puddles architecture
- Added full example project: ["Scrumdinger in Puddles"](https://github.com/SwiftedMind/Scrumdinger) – A re-implementation of Apple's Scrumdinger tutorial app.
- Added support for watchOS 8+ and tvOS 15+.
- Added "Target States" functionality to `Providers` (formerly known as `StateConfiguration`, which was only available in a `Navigator`)

### Changed

- Unified `Coordinator` and `Provider`. Those types were almost identical from a technical as well as semantic perspective, so `Coordinator` has been renamed to `Provider`.
- Renamed `Interface.handled(by:)` to `Interface.consume(_:)` and `Interface.forward(to:)` to clarify functionality
- Renamed `Interface.unhandled` to `Interface.ignore` to clarify functionality
- Renamed `Interface.sendAction(_:)` to `Interface.fire(_:)` to de-conflict with Xcode's `.self` auto-complete suggestion, which always forces you to type `sen` to get the correct completion.
- Unified the`QueryableItem` and `Queryable` property wrappers. Both are now called `Queryable`. Slightly more verbose (since you always have to specify 2 generic arguments, even if the first one is `Void`), but much more clearer and discoverable.
- Redesigned how `Queryables` work behind the scenes. They should now work more reliably. 
    - `queryableAlert` and `queryableConfirmationDialog` might still glitch in some edge cases when cancelling an ongoing query and then immediately starting a new query. This is due to some strange SwiftUI behavior with replacing presented alerts and confirmation dialogs with new ones. Workaround is adding a small time delay between cancellation and the new query.
- Renamed `StateConfiguration` to `TargetState` to clarify its purpose.
- Renamed the `Signal` property wrapper to `TargetStateSetter` to clarify its purpose.
- Renamed `queryableHandler(controlledBy:queryHandler:)` to `queryableClosure(controlledBy:block:)` to clarify its purpose.
- Renamed `Navigator.root` to `Navigator.entryView` to make it more similar to `Provider`, since they both do the exact same thing, basically.

### Fixed

- Fixed macOS support
