# SensetiveLogger
Logger, destinations for erasing sensitive fields.

## Usage

### Initialization
To initialize `SensetiveLogger` need pass to init object, that inplements `Logger` protocol.
#### Example
```swift
let sensitiveLogger = SensitiveLogger(logger: NSLogLogger())
```

### Settings
If need to turn on/off sensitive erasing in runtime.
```swift
log.excludeSensitive(false) // Thread-safe
```

### Erase using custom interpolation
You can use interpolations to erase values. By default interpolations in `SensetiveLogger` erase values. To show value you need to call interpolation with `public:` label.
#### Example
```swift
let message = "Test message"
sensitiveLogger.debug(label: "", message: "\(public: message)")
sensitiveLogger.debug(label: "", message: "\(message)")
```
#### Output
1. `Test message`
2. `<private>`



### Erase using property wrappers
For your conviniance you can mark special propeties to make them erased.
You need to implement Loggable protocol and mark sensetive properties using `@Sensetive` propperty wrapper to make property values erased on object logging.

#### Example
```swift
struct Model: Loggable {
    @Sensitive var first = ""
    var second = 0
}
```

After that you can just call log function
```swift
sensitiveLogger.debug(label: "", message: "\(model)")
```

#### Output
`_first: <private>, second: 0`