# Changelog

## 1.0.0 (Upcoming)

### Added

- Added documentation for the Puddles architecture
- Added full example project: ["Scrumdinger in Puddles"](https://github.com/SwiftedMind/Scrumdinger) – A re-implementation of Apple's Scrumdinger tutorial app.
- Added support for watchOS 8+ and tvOS 15+.

### Changed

- Unified `Coordinator` and `Provider`. Those types were almost identical from a technical as well as semantic perspective, so `Coordinator` has been renamed to `Provider`.
- Renamed `Interface.handled(by:)` to `Interface.consume(_:)` and `Interface.forward(to:)` to clarify functionality
- Renamed `Interface.unhandled` to `Interface.ignore` to clarify functionality
- Renamed `Interface.sendAction(_:)` to `Interface.fire(_:)` to de-conflict with Xcode's `.self` auto-complete suggestion, which always forces you to type `sen` to get the correct completion.
- Renamed the`QueryableItem` property wrapper to `QueryableWithInput` to clarify its purpose.
- Renamed `StateConfiguration` inside `Navigator` to `TargetState`
- Renamed the `Signal` property wrapper to `TargetStateSetter` to clarify its purpose.

### Fixed

- Fixed macOS support
