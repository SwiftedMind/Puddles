# Changelog

## 2.0.0

This release mainly removes the dependency to `Queryable` because that should be treated as a fully separate package. Check it out at [https://github.com/SwiftedMind/Queryable](https://github.com/SwiftedMind/Queryable).

Removing this should make it less likely to force major releases on Puddles. 

### Changed

- Renamed the concept of adapters to containers since now they are simple `DynamicProperty` structs with a lot more power and generalized use! A detailed explanation will be provided on swiftedmind.com.

### Removed

- Removed `Signal`. This will be coming as a separate Swift package.
- Removed the dependency to `Queryable`, since that is fully separate and makes breaking changes harder to control. Simply add `Queryable` to your project, to keep using it. 

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
