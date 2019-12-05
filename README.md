Robologs
========

Robologs is a logging framework for Swift.

## The core concepts

There is a protocol `Logger` - that requires only one function to be implemented:
```swift
@inlinable
func log(
    priority: Priority,
    label: String,
    message: () -> String,
    meta: () -> [String: Any]?,
    file: StaticString,
    function: StaticString,
    line: UInt
)
```
#### Log levels (Priority)

The following log levels are supported:

- `verbose` - Describes the same events as in the debug-level but in more detail.
- `debug` - Describes messages that contain information typically used only when debugging a program.
- `info` - Describes informational messages.
- `warning` - Describes conditions that are not erroneous, but may require special processing.
- `error` - Describes a non-critical application error.
- `critical` - Describes a critical error, after which the application will be terminated.

Log levels implement the `Comparable` protocol and their priority is in ascending order from `verbose` to `critical`.
If your custom logger needs to handle a certain log level, just compare it with `priority` parameter in  `log` - function.

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

## Usage

Create your custom `Logger` implementation or take out of the box and use it like this:
```swift
let logger: Logger = MyLogger()
logger.debug(label: "Network", message: "User data request",
             meta: [ "RequestId": UUID().uuidString ])
```
Several implementations are available out of the box (the list will be updated):
- `PrintLogger` which just prints log message in LLDB-console.
- `OSLogLogger` which incapsulates `os.log` logging system.

## Logging sensitive data

When logging events, the confidentiality of certain data must be considered.

The logging system under the hood retrieves log information using protocols:
- `CustomStringConvertible`
- `CustomDebugStringConvertible`
- `CustomReflectable`
- `CustomLeafReflectable`

Therefore, you need to implement a simple `@propertyWrapper` into your project that will clear private information in accordance with your rules:
```swift
@propertyWrapper
struct Sensitive<Value>: CustomStringConvertible, CustomDebugStringConvertible,
        CustomReflectable, CustomLeafReflectable {
    var wrappedValue: Value
    var description: String { "<private>" }
    var debugDescription: String { "<private>" }
    var customMirror: Mirror { Mirror(reflecting: "<private>") }
}
```
And use it in your data models like this:
```swift
struct User {
    let name: String
    @Sensitive private(set) var cardNumber: String
}
```

## Requirements

- iOS 10.0+
- Swift 5.0+
  - Xcode 10.2+
  
## Installation

Robologs is available through [Carthage](https://github.com/Carthage/Carthage) or [SwiftPM](https://swift.org/package-manager/)
  
#### Carthage

To install Robologs with Carthage, add the following line to your `Cartfile`.
```
git "https://git.redmadrobot.com/RedMadRobot/SPb/robologs-ios.git"
```
Then run `carthage update --no-use-binaries` command or just `carthage update`.
  
#### SwiftPM

To install Robologs with SwiftPM using XCode 11+, add package in project settings "Swift Packages" tab using url:
```
"https://git.redmadrobot.com/RedMadRobot/SPb/robologs-ios.git"
```
or add the following package to your Package.swift file: 
```swift
.package(url: "https://git.redmadrobot.com/RedMadRobot/SPb/robologs-ios.git")
```

