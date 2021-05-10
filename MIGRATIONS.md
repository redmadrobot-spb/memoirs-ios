# Version 3 — Version 4

## Big renaming

 - `Logger` protocol → `Loggable` (more Swifty?)
 - `Loggable` protocol (for marking types) → `LogStringConvertible` (same as `CustomStringConvertable`)
 - `LabeledLogger` can be replaced with `Logger` in most cases. You can leave `LabeledLogger` if you want to specify `scopes` manually. 

## Scopes introduction

Now logs contain Scopes, that specify where in the app log was emitted. This can be used to group similar logs. 

## Ability to specify time of log

Now `Loggers` are able to get time from the caller. If non specified, `Date()` will be used.

## Ability to measure time of code execution

Using `Stopwatch`, you can measure time execution of code. 
