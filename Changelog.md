# Changelog

## 1.0.0

### Added

- Added landing page for the project: [swiftedmind.com/puddles](https://www.swiftedmind.com/puddles)
- Added documentation for the Puddles architecture
- Added full example project: ["Scrumdinger in Puddles"](https://github.com/SwiftedMind/Scrumdinger) – A re-implementation of Apple's Scrumdinger tutorial app
- Added support for watchOS 8+ and tvOS 15+
- Added Signals (previously known as `StateConfiguration`, but now useable in any SwiftUI View)

### Changed

- Removed `Coordinator` and `Provider`. The architecture has evolved to a point where these have become unnecessary overhead and bloat.
- Removed `Navigator`, as it has moved from being a protocol type to a concept within the Puddles architecture.
- Renamed `Interface.handled(by:)` to `Interface.consume(_:)` and `Interface.forward(to:)` to clarify functionality
- Renamed `Interface.unhandled` to `Interface.ignore` to clarify functionality
- Removed the `QueryableItem` and `Queryable` property wrappers, since they have moved to a dedicated package: [Queryable](https://github.com/SwiftedMind/Queryable)

### Fixed

- Fixed macOS support
