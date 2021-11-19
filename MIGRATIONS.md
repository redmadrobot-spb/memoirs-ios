# From 0.9 to 1.0

## FilteringMemoir configuration

Previously filters were matched by "label", now they are matched by tracers. This means two things:
 - all labels should be changed into tracers. For labels, you can use `.label("...")`, for types: `tracer(for: <Type>.self)`
 - init parameter name changed from `configurationsByLabel` to `configurationsByTracer`.

Some `FilteringMemoir.Configuration` properties did change their names too to be more descriptive.

## TracedMemoir

`TracedMemoir` changed a little, now it distinguishes between label tracers and type tracers. This allows to better
represent:
- Swift types, that can be nested, can have generics
- Multi-module projects

Also `TracedMemoir` now is more flexible. It can get tracer as initialization parameter,
`TracedMemoirs` can be _nested_ (`with(tracer:)` method). This is very useful for Contexts

## Tracer

- New Tracer appeared for this (.type(name, module))
- .request tracer changed name from `id` to `trace`

## MemoirContext

New `MemoirContext` appeared. This type for now contains only memoir, but in the future it should expand with other
objects. If you need to use memoirs for tracing purposes, please use `MemoirContext`. Details can be found in README.md.

# From Robologs to Memoirs 0.x

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
