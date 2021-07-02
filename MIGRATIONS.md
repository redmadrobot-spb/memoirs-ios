# From Robologs to Memoirs 

## Big renaming

- `Logger` protocol → `Memoir`. All loggers are now memoirs, they can do more, then logging. Easier to separate from other loggers too.
- `LogString` → `SafeString` 
- `Loggable` protocol (for marking types) → `SafeStringConvertible` (same as `CustomStringConvertable`).
- `LabeledLogger` → `TracedMemoir`. You can specify tracer manually there, or use shortcut with string/object label.
- `Level` → `LogLevel`
- Removed logger that adds thread and queue info. Looks like thread name is hard to find anyway, queue name can't be found for all the OSes and it can lead to a crash.

### Tracers

Before we've stored item parameters and tracing information together in the `meta` property. That was hard to process and analyze. 
Now there are two properties: `meta` that should contain only item parameters (you can look at it as a structured part of the item) and 
`tracers` that are special item grouping markers.

In terms of migration, please replace `LabeledLogger` with `TracedMemoir` (and change parameter name from `logger` to `memoir`), other should work.

## Ability to specify time of memoir item

Now `Memoirs` receive time as argument. If non specified, `Date()` will be used.
