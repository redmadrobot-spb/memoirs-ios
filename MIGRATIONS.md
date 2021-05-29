# Version 3 — Version 4

## Big renaming

- `Logger` protocol → `Memoir`. All loggers are now memoirs, they can do more, then logging. Easier to separate from generic loggers too.
- `LogString` → `SafeString` 
- `Loggable` protocol (for marking types) → `SafeStringConvertible` (same as `CustomStringConvertable`).
- `LabeledLogger` → `TracedMemoir`. You can specify tracer manually there, or use shortcut with string/object label.
- `Level` → `LogLevel`
- Removed logger that adds thread and queue info. Looks like thread name is hard to find anyway, queue name can't be found for all the OSes and it can lead to a crash.

## Memoir items

Before we've had only `message` and `meta`. Now there is a memoir item. Every item has `meta` (as in item parameters) and `tracers` (read about them below).
Items can be:
- `log.` Log has a message and level, and should be used as a programming log.
- `event.` It has only a name.
- `measurement`. It has a name and a value. Values have type `Double`, usually it will be some `TimeInterval`, but it can be anything you want.
- `tracer`. Let's talk about them a little more.

#### Tracers

Before we've stored item parameters and tracing information together in the `meta` property. That was hard to process and analyze. 
Now there are two properties: `meta` that should contain only item parameters (you can look at it as a structured part of the item) and 
`tracers` that are special item grouping markers. Things that can be represented by tracers are:
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

## Ability to specify time of memoir item

Now `Memoirs` receive time as argument. If non specified, `Date()` will be used.

## Ability to measure time of code execution

Using `Stopwatch`, you can measure time execution of code. After measurement is complete, feel free to send it to a memoir. 
