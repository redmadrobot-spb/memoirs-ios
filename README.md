Robologs
========

Robologs is a logging framework for Swift.

## The core concepts

There is a protocol `Logger` - that requires only one function to be implemented:
```swift
/// Required method that reports the log event.
/// - Parameters:
///   - priority: Log-level.
///   - file: The path to the file from which the method was called.
///   - function: The function name from which the method was called.
///   - line: The line of code from which the method was called.
///   - label: Label describing log category.
///   - message: Message describing log event.
///   - meta: Additional log information in key-value format.
@inlinable
func log(
    priority: Priority,
    file: StaticString,
    function: StaticString,
    line: UInt,
    label: String,
    message: () -> String,
    meta: () -> [String: Any]?
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
func verbose(file:function:line:label:message:meta:)
func debug(file:function:line:label:message:meta:)
func info(file:function:line:label:message:meta:)
func warning(file:function:line:label:message:meta:)
func error(file:function:line:label:message:meta:)
func critical(file:function:line:label:message:meta:)
```

## Usage

Create your own `Logger` implementation or take out of the box and use it like this:
```swift
let logger: Logger: = MyLogger()
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

