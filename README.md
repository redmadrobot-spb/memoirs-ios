# Memoirs

Memoirs is a logging framework for Swift apps and more.

Main features
 - log stuff locally (to the console, to system logs or else),
 - measure performance of code blocks in a uniform way,
 - capture analytics events.

It provides default implementation of all these things, but your project may require something else. Feel free to implement your 
own loggers and Stopwatches, to do whatever stuff you need.

## Installation

Only [Swift Package Manager](https://swift.org/package-manager/) is supported.

#### Requirements

- iOS 11+, macOS 11+, Linux.
- Swift 5.3+

#### Swift Package Manager

To install Memoirs with SwiftPM using XCode, add package in project settings "Swift Packages" tab using url:
```swift
"https://git.redmadrobot.com/RedMadRobot/SPb/Robologs/sdk-apple.git"
```
or add the following package to your Package.swift file:
```swift
.package(url: "https://git.redmadrobot.com/RedMadRobot/SPb/Robologs/sdk-apple.git")
```

## Memoir items

Items can be:
- `log.` Log has a message and level, and should be used as a programming log.
- `event.` It has only a name.
- `measurement`. It has a name and a value. Values have type `Double`, usually it will be some `TimeInterval`, but it can be anything you want.
- `tracer`. Basic things for item grouping and tracing.

Every item has `meta` (as in item parameters) and `tracers` (read about them below).

#### Tracers

There are two properties: `meta` that should contain only item parameters (you can look at it as a structured part of the item itself) and
`tracers` that are special item grouping markers. Some things that can be represented by tracers are:
- Application: `app:{bundleId}`.
- Application instance (installation on a specific device): `instance:{instanceId}`.
- Application session: `session:{userId}`.
- Request: `request:{requestId}` for tracing requests to/from the backend.
- Item label (usually based on app subsystem or class that emitted the item): `{label}`.
- etc.

Each tracer has:
- `name` (String). Tracers are matched by this string, please make sure that they differ meaningfully.
  This is why application tracers contain ids for example. If they all are just `app` we will not be able to differentiate one app from another.
- `meta`. Tracer parameters. These are updated with the `Memoir.update(tracer:...)` method, and they are active till next `update`.

Tracer can have its scope from first update to `end`. Tracer `end` isn't a guarantee.

Usually you create `TracedMemoir`, and it creates corresponding tracer for you. You can stack `TracedMemoirs` if you want.

There are several generic `TracedMemoirs` for your convenience: `AppMemoir`, `InstanceMemoir`, `SessionMemoir`.

### Logging

#### Log levels (Level)

The following log levels are supported:
- `critical` - Describes a critical error, after which the application will be terminated.
- `error` - Describes a non-critical application error.
- `warning` - Describes conditions that are not erroneous, but may require special processing.
- `info` - Describes informational messages.
- `debug` - Describes messages that contain information typically used only when debugging a program.
- `verbose` - Describes the same events as in the debug level but in more detail.

There are methods for each level (`memoir.debug`, `memoir.critical` and so on).

### Events

If you want to describe analytics event (or any other kind of event), you can with `event` item. It does not have level, only string name.
It also does have `meta` (parameters) and `tracers` to be able to connect it to other memoir items.

### Measurements

Measurements also do not have level, only `name` and `value`. Name is a `String`, value is a `Double` (aka `TimeInterval` aka `CGFloat`).

To measure time intervals, you can use `Stopwatch` like this:
```swift
let stopwatch = Stopwatch(memoir: someMemoir)
let mark = stopwatch.mark
... // do some stuff
let newMark = stopwatch.measureTime(from: mark, name: "MyMeasurement" /* meta, tracers if needed */)
```

or using closure-based API:
```swift
stopwatch.measure(name: "AnotherMeasurement" /* meta, tracers if needed */) {
    ... // do some other stuff
}
```

## Usage

Create your custom `Memoir` implementation or use one of the standard:
```swift
let genericMemoir = MultiplexingMemoir(memoirs: [
    PrintMemoir(),
    MyCustomMemoir(...)
])

let memoir = TracedMemoir(label: "Network", memoir: genericMemoir)
memoir.debug("User data request")
memoir.event(name: "Button pressed", meta: [ "ButtonName": "SpendMoney" ])
memoir.measurement(name: "TimeOnBuyScreen", value: 23.9)
```

Several log implementations to use:
 - `PrintMemoir` which outputs items to the console.
 - `OSLogMemoir` which uses `os.log` system.
 - `NSLogMemoir` which uses `NSLog` system.

There are some structural memoirs, that do not do logging themselves but instead redirect items to others: 
 - `FilteringMemoir` which filters incoming items by levels and parameters (different ones for each label).
 - `MultiplexingMemoir` which redirects items to several other memoirs.
 - `TracedLogger` which adds specific tracer to all items. You can nest them easily if neede.
