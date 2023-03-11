# Changelog

## 1.0.0 (Upcoming)

### New

- Added documentation for the Puddles architecture

### Changed

- Unified `Coordinator` and `Provider`. Those types were almost identical from a technical as well as semantic perspective, so `Coordinator` has been renamed to `Provider`.
- Renamed `Interface.handled(by:)` to `Interface.consume(_:)` and `Interface.forward(to:)` to clarify functionality
- Renamed `Interface.unhandled` to `Interface.ignore` to clarify functionality
- Added support for watchOS 8+ and tvOS 15+.

### Fixed

- Fixed macOS support
