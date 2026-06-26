# swift-streams

Minimal `InputStream` and `OutputStream` protocols built on `Span` and
`MutableSpan` for zero-copy, allocation-free I/O. Designed for
performance and latency sensitive code such as sockets, pipes, and files.

![License](https://img.shields.io/badge/License-MIT-green.svg)
![Platforms](https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20visionOS%20%7C%20watchOS-blue.svg)
![Swift](https://img.shields.io/badge/Swift-6.2-orange.svg)

## Overview

Two one-directional stream protocols that read into, and write from, a buffer
the **caller** owns:

- **Allocation-free** — the caller supplies the buffer, so a stream allocates no
  storage of its own.
- **Typed throws** — each protocol declares its own error type (`ReadFailure` /
  `WriteFailure`); a stream that cannot fail uses `Never` and drops error
  handling from the hot path entirely.
- **Non-copyable friendly** — protocols are `~Copyable`, so a conformer can model
  exclusive ownership of an underlying resource (e.g. a file descriptor).

`Array` (and any `RangeReplaceableCollection`) conforms out of the box, behaving
as a FIFO: `read` drains from the front, `write` appends to the back.

## Requirements

- Swift 6.2+

## Installation

Add the package to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/Tyr0/swift-streams.git", from: "1.0.0"),
]
```

Then add `Streams` to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "Streams", package: "swift-streams"),
    ],
),
```

## Usage

**Write** elements from a buffer into an `OutputStream`:

```swift
import Streams

var sink = Array<UInt8>()
let payload = Array<UInt8>("Hi".utf8)

payload.withUnsafeBufferPointer { pointer in
    _ = sink.write(pointer.span)   // sink == [0x48, 0x69]
}
```

**Read** elements from an `InputStream` into a buffer:

```swift
var source = Array<UInt8>([0x48, 0x69])
var buffer = Array<UInt8>(repeating: 0, count: 2)

let count = buffer.withUnsafeMutableBufferPointer { pointer in
    var span = pointer.mutableSpan
    return source.read(into: &span)   // count == 2; source is now empty
}
```

Consume any stream generically via its primary associated types — keeping the
call statically dispatched and allocation-free:

```swift
func drain<Source>(_ source: inout Source, into buffer: inout MutableSpan<UInt8>) -> Int where Source: InputStream<UInt8, Never> {
    source.read(into: &buffer)
}
```

## API

#### InputStream Protocol

```swift
public protocol InputStream<Element, ReadFailure>: ~Copyable {
    associatedtype Element
    associatedtype ReadFailure: Error

    mutating func read(into mutableSpan: inout MutableSpan<Element>) throws(ReadFailure) -> Int
}
```

#### OutputStream Protocol

```swift
public protocol OutputStream<Element, WriteFailure>: ~Copyable {
    associatedtype Element
    associatedtype WriteFailure: Error

    mutating func write(_ span: borrowing Span<Element>) throws(WriteFailure) -> Int
}
```

Both methods return the number of elements transferred, which may be fewer than
the buffer holds; `read` returns `0` at end of stream. Conform your own types to
expose sockets, pipes, ring buffers, and other sources and sinks.

## License

Released under the MIT License. See [LICENSE.md](LICENSE.md).
