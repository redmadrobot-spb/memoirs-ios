# Robologs

Robologs is a logging framework for Swift, that can:
 - log stuff locally (to the console, to system logs or else),
 - log stuff remotely (from the iPhone to your Mac via WiFi for example or to QA Mac via server, if you have one),
 - measure performance of code blocks in a uniform way,
 - capture analytics events.

It provides default implementation of all these things, but your project may require something else. Feel free to implement your 
own loggers and Stopwatches, to do whatever stuff you need.

Please refer to [Logging](#Logging) or [Performance Monitoring](#Performance Monitoring) sections for more information.

## Installation

Only [Swift Package Manager](https://swift.org/package-manager/) is supported.

#### Requirements

- iOS 9.0+
- Swift 5.0+
- Xcode 10.2+

#### Swift Package Manager

To install Robologs with SwiftPM using XCode 12+, add package in project settings "Swift Packages" tab using url:
```swift
"https://git.redmadrobot.com/RedMadRobot/SPb/Robologs/sdk-apple.git"
```
or add the following package to your Package.swift file:
```swift
.package(url: "https://git.redmadrobot.com/RedMadRobot/SPb/Robologs/sdk-apple.git")
```

**Warning**: _If the dependency is in the final project or if another dependency depends on [swift-protobuf](https://github.com/apple/swift-protobuf), problems may occur if the versions do not match. To solve this problem, install Robologs manually._

# Logging

## The core concepts

There is a protocol `Logger` - that has only one method:
```swift
@inlinable
func log(
    level: Level,
    _ message: @autoclosure () -> LogString,
    label: String,
    scopes: [Scope],
    meta: @autoclosure () -> [String: LogString]?,
    date: Date,
    file: String,
    function: String,
    line: UInt
)
```

#### Log levels (Level)

The following log levels are supported:

- `critical` - Describes a critical error, after which the application will be terminated.
- `error` - Describes a non-critical application error.
- `warning` - Describes conditions that are not erroneous, but may require special processing.
- `info` - Describes informational messages.
- `debug` - Describes messages that contain information typically used only when debugging a program.
- `verbose` - Describes the same events as in the debug level but in more detail.

#### Convenience interface

As default implementation `Logger` has list of functions each of which corresponds to specific log level. For convenience, it is recommended to use them when logging.
```swift
func verbose(label:message:meta:file:function:line:)
func debug(label:message:meta:file:function:line:)
func info(label:message:meta:file:function:line:)
func warning(label:message:meta:file:function:line:)
func error(label:message:meta:file:function:line:)
func critical(label:message:meta:file:function:line:)
```

#### Labels

Every log has a label as an easy way of grouping. Usually label is derived from the type that emits logs or from the file, or from the subsystem.
Robologs has specific logger (`LabeledLogger`) that will add label for you automatically.

#### Scopes

Each log message can be a part of one or several Scopes. Scopes are another things to group log messages, 
and they can do it hierarchically. For example, hierarchies (and corresponding scopes) can be:
 - Application
    - → Installation
        - → Foreground run (session)
            - → Specific Flow
                - → Specific Screen
    - → Main thread/queue
        - → My queue targeted to the main queue
    - → Global queue / specific background thread
    - → User session

Each log can be a part of any number of scopes, for example: `[ "Auth Flow", "Main queue" ]`. If log is a part of some Scope, 
it is a part of parent scopes as well. In our example full list of Scopes that log is in: 
`[ "Application", "Installation", "Session", "Auth Flow", "Main queue" ].`

#### Message and Meta

Meta parameter can be used for structural log information, and message is non-structural kind-of-string thing that has same purpose.

## Usage

Create your custom `Logger` implementation or take out of the box and use it like this:
```swift
let genericLogger = MultiplexingLogger(loggers: [
    PrintLogger(),
    AnotherCustomLogger(...)
])

let logger = LabeledLogger(label: "Network", logger: genericLogger)
logger.debug("User data request")
```

Several log implementations to use:
 - `PrintLogger` which prints log message to the console.
 - `OSLogLogger` which uses `os.log` logging system.
 - `NSLogLogger` which uses `NSLog` logging system.

There are some structural loggers, that do not do logging themselves but instead redirect logs to others: 
 - `FilteringLogger` which filters incoming logs by levels (different ones for each label).
 - `MultiplexingLogger` which redirects logs to several other loggers.
 - `LabeledLogger` which adds specific label to all logs.
 - `ScopedLogger` which adds specific scopes to all logs.

### Remote Logging

## Self-signed certificate.
If you are using `RemoteLogger` and server where you sending logs is using self signed certificate, use AllowSelfSignedChallengePolicy().
Also you can implement `AuthenticationChallengePolicy` protocol for more specific requirements for URLAuthentificationChallenge 

```swift
let remoteLogger = RemoteLogger(
                    endpoint: url,
                    secret: secret,
                    challengePolicy: AllowSelfSignedChallengePolicy()
)
```
