# Memoirs

Memoirs is a logging framework for Swift apps and more.

Main features
 - log stuff locally (to the console, to system logs or else),
 - measure performance of code blocks in a uniform way,
 - capture analytics events.

It provides default implementation of all these things, but your project may require something else. Feel free to implement your own Memoirs and Stopwatches, to do whatever stuff you need.

## Installation

Only [Swift Package Manager](https://swift.org/package-manager/) is supported.

#### Requirements

- iOS 11+, macOS 11+, Linux.
- Swift 5.3+

#### Swift Package Manager

To install Memoirs with SwiftPM using XCode, add package in project settings "Swift Packages" tab using url:
```swift
"git@github.com:redmadrobot-spb/memoirs-ios.git"
```
or add the following package to your Package.swift file:
```swift
.package(url: "git@github.com:redmadrobot-spb/memoirs-ios.git")
```

## Memoir items

Items are things that `Memoirs` can handle. Each item has `tracers` and `meta` with properties. But each item has its own main properties. They are:
- `log` has a `message` and `level`, and should be used as a development log.
- `event` has only a `name`.
- `tracer,` that allows to connect different items together by some kind of a marker.
- `measurement` has a `name` and a `value`. Values can have different types: `Double` (usually it will be some `TimeInterval`), `Int64` (maybe a counter), `meta` (does not have a value and uses `meta` dictionary to store data) and `histogram`, that is used to store data distributed values.

#### Tracers

`tracers` that are special item grouping markers. Each tracer has a name. Tracers are matched using this name, so it's up to Application developer to find out how to separate one tracer from another. Please name them accordingly:

Here are examples of standard tracers:
- Application tracer, that has id `app:{bundleId}`.
- Application instance tracer (installation on a specific device) with id `instance:{instanceId}`.
- Application session tracer, id: `session:{userId}`.
- Network request tracer, id: `request:{requestId}`. Can be used for tracing requests/responses to/from the backend.
- Item label, that is usually based on app subsystem or class that emitted the item: `{label}`.
- etc.

Tracers have their lifetime from first usage to special item, that is called tracer end. End is not a guarantee (app can die and not end some of its tracers), but it can be very useful. For example, label tracers that are created with `TracedMemoir` are updated when initialized and ended when class is deinitialized. So you can basically see the lifetime of the specific object in the log. 

Usually you create `TracedMemoir`, and it creates corresponding tracer for you. You can stack `TracedMemoirs` if you want. If you want, you can send tracer items to memoirs by yourself.

There are several generic `TracedMemoirs` for your convenience, like `AppMemoir`, `InstanceMemoir` and `SessionMemoir`.

#### Meta

Meta property is a dictionary that can hold item parameters if needed. Please keep it simple and concise, it can't hold lots of data and can't be hierarchical.

#### Safe Strings

Memoirs uses the concept of `SafeString`, that holds all values that can contain sensitive information. When you are sending a log, or `meta` properties, each value is a `SafeString`.

Some Memoirs (`PrintMemoir`) does not use safe strings, and prints everything. This is because this can't (and shouldn't) be used in production, and all printed values are for developer eyes only. Other Memoirs have initialization property `isSensitive`, that shows, do Memoirs should remove sensitive data from the items or not.

By default all data is sensitive. This means that if `isSensitive` is `false`, data will appear in the output, and if it is `true`, it will be omitted.

You can mark data as:
- _safe_, that means it will be shown everywhere.
- _sensitive_ (default), that will hide data when `isSensitive` is true
- _topSecret_, that will hide data everywhere from the output.

Marking can be done in two ways:
- When constructing `SafeString` from literal interpolation: 
   - default (sensitive): "Log data: \(data)"
   - safe: "Log data: \(safe: data)"
- When designing model types, with property wrappers and implementing `SafeStringConvertible` marker protocol:
   - `@LogNever` will forbid outputting the property,
   - `@LogSensitive` will output only when `isSensitive` is false,
   - `@LogAlways` will output all the time.

So if you develop some kind of _User_ type, it can look like this:

```swift
struct User: SafeStringConvertible {
    @LogAlways
    var id: String
    @LogSensitive
    var name: String
    @LogNever
    var password: String
}
```

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

Measurements also do not have level, only `name` and `value`. Name is a `String`. Values can have different types:
- `Double` (usually it will be some `TimeInterval`),
- `Int64` (maybe a counter),
- `meta` (does not have a value and uses `meta` dictionary to store data)
- `histogram`, that is used to store data distributed values.

To measure time intervals, you can use `Stopwatch` like this:
```swift
let stopwatch = Stopwatch(memoir: someMemoir)
var mark = stopwatch.mark
... // do some stuff
mark = stopwatch.measureTime(from: mark, name: "MyMeasurement" /* meta, tracers if needed */)
... // can measure next interval now
```

or using closure-based API:
```swift
stopwatch.measure(name: "AnotherMeasurement" /* meta, tracers if needed */) {
    ... // do some other stuff
}
```

Feel free to add custom measurements too:

```swift
memoir.measurement(name: "Counter", value: .int(counterValue))
memoir.measurement(name: "MetaBasedMeasurement", value: .meta, meta: [ "key": "value" ])
```

## Contexts

`TracedMemoir` is designed to be able to hold information about the logging place. Usually in loggers, this is 
specified by a string (that is sometimes derived from the type name), but this does not tell the whole story. 
For example, if you have a service, that can be called from different parts of the app, all logs from the service will
have identical mark.

To be able to distinguish calls from different parts of the app, service must know source of the calls. This knowledge
can be encapsulated in `MemoirContext`, and sent to the service. In the service we get `tracedMemoir` from the context, 
create new memoir with local tracer (`tracedMemoir.with(tracer: localServiceTracer)`), and use it for logging and all 
other things.

## Configuration and usage

You can configure, how log levels and other items are marked with this method:

```swift
LogLevel.configure(..., stringForDebug: "DEBUG", ...)
```

Create your custom `Memoir` implementation or use one of the standard:
```swift
let printMemoir = PrintMemoir(shortCodePosition: true, shortTracers: true)

let appMemoir = AppMemoir(memoir: printMemoir)
let instanceMemoir = InstanceMemoir(memoir: appMemoir)

let memoir = FilteringMemoir(
    memoir: MultiplexingMemoir(memoirs: [ instanceMemoir ]),
    defaultConfiguration: .init(level: .debug),
    configurationsByLabel: [
        "SomeLabelTracerName": .init(level: .info),
        "AnotherLabelTracerName": .init(level: .verbose),
    ]
)
```

After this you can use `memoir` as a base to add specific memoirs into classes and subsystems:

```swift
class MyClass {
    private var memoir: TracedMemoir!
    
    init(..., memoir: Memoir) {
        self.memoir = TracedMemoir(object: self, memoir: memoir)
        self.memoir.debug("init")
    }
}
```

Several basic implementations to use:
 - `PrintMemoir` which outputs items to the console.
 - `OSLogMemoir` which uses `os.log` system.
 - `NSLogMemoir` which uses `NSLog` system.
 - `VoidMemoir` that discards all items.

There are some structural memoirs, that do not do logging themselves but instead redirect items to others: 
 - `FilteringMemoir` which filters incoming items by levels and parameters (different ones for each label).
 - `MultiplexingMemoir` which redirects items to several other memoirs.
 - `TracedLogger` which adds specific tracer to all items. You can nest them easily if need.

### Testing

If you need to test, what memoirs are outputting, please set `Memoir.Output.logInterceptor` closure. It will be called from all basic memoir implementations.

#### License

MIT License, https://github.com/redmadrobot-spb/memoirs-ios/blob/main/LICENSE
