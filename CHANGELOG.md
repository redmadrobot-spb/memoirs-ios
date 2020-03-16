# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## UNRELEASED
### Removed
- Default `log`-function in `Logger`

## Added
- Added `SensetiveLogger`

## [1.3.0](https://git.redmadrobot.com/RedMadRobot/SPb/robologs-ios/tags/1.3.0) - 2019-12-25
### Added
- Default `log`-function in `Logger`

## [1.2.0](https://git.redmadrobot.com/RedMadRobot/SPb/robologs-ios/tags/1.2.0) - 2019-12-25
### Changed
- `StaticString` to `String` in `log`-functions

### Fixed
- Appearance of empty log parameters in print loggers

## [1.1.0](https://git.redmadrobot.com/RedMadRobot/SPb/robologs-ios/tags/1.1.0) - 2019-12-24
### Changed
- Minimum deployment target to iOS 9.0
- Logging level `Priority` renamed to `Level`

## [1.0](https://git.redmadrobot.com/RedMadRobot/SPb/robologs-ios/tags/1.0) - 2019-12-17
### Added
- [FilteringLogger](https://git.redmadrobot.com/RedMadRobot/SPb/robologs-ios/blob/master/Sources/Loggers/FilteringLogger.swift)
- [MultiplexingLogger](https://git.redmadrobot.com/RedMadRobot/SPb/robologs-ios/blob/master/Sources/Loggers/MultiplexingLogger.swift)
- [NSLogLogger](https://git.redmadrobot.com/RedMadRobot/SPb/robologs-ios/blob/master/Sources/Loggers/NSLogLogger.swift)
- [LabeledLogger with adapter](https://git.redmadrobot.com/RedMadRobot/SPb/robologs-ios/blob/master/Sources/Loggers/LabeledLogger/LabeledLogger.swift)

### Changed
- The type of `meta` parameter in the `Logger` protocol from `[String: Any]` to `[String: String]`.

### Removed
- Section about sensitive data in README

### Fixed
- `OSLogLogger` public init


## [0.1.1](https://git.redmadrobot.com/RedMadRobot/SPb/robologs-ios/tags/0.1.1) - 2019-12-5
### Fixed
- Log priority parameters in `Logger` extension functions


## [0.1](https://git.redmadrobot.com/RedMadRobot/SPb/robologs-ios/tags/0.1) - 2019-12-5
### Added
- Documentation
- Swiftlint support
- SwiftPM support
- [OSLogLogger](https://git.redmadrobot.com/RedMadRobot/SPb/robologs-ios/blob/master/Sources/Loggers/OSLogLogger.swift)
- [PrintLogger](https://git.redmadrobot.com/RedMadRobot/SPb/robologs-ios/blob/master/Sources/Loggers/PrintLogger.swift)
