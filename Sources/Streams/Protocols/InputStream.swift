
/// A type that produces elements by reading them into a caller-supplied buffer.
///
/// An input stream is a one-directional source of elements — such as a file, a
/// socket, or a pipe — that you consume by reading into a region of memory you
/// already own. Reading is destructive: every element a stream yields is
/// consumed, and a stream never produces the same element twice.
///
/// You read from a stream by handing a mutable view over your buffer to the
/// ``read(into:)`` method. The stream copies as many elements as the buffer can
/// hold, up to the number it currently has available, and returns the count it
/// wrote. Because the caller owns the destination buffer, a stream allocates no
/// storage of its own, which makes the protocol suitable for performance- and
/// latency-sensitive contexts.
///
///     var buffer = Array<UInt8>(repeating: 0, count: 1024)
///     let count = buffer.withUnsafeMutableBufferPointer { pointer in
///         var span = pointer.mutableSpan
///         return try source.read(into: &span)
///     }
///     // The first `count` elements of `buffer` are now valid.
///
/// A single call may read fewer elements than the buffer can hold, even when
/// more remain in the source; read in a loop until you have consumed as many
/// elements as you need. A return value of `0` indicates that the stream has
/// reached its end and has no further elements to produce.
///
/// Because `InputStream` does not require `Copyable`, a conforming type may be
/// non-copyable — letting it model exclusive ownership of an underlying
/// resource, such as a file descriptor — but copyable types may conform as
/// well.
@available(iOS 12.2, macOS 10.14.4, tvOS 12.2, visionOS 1.0, watchOS 5.2, *)
public protocol InputStream<Element, ReadFailure>: ~Copyable {

    /// A type representing the stream's elements.
    associatedtype Element

    /// The type of error this stream throws when a read fails.
    associatedtype ReadFailure: Error

    /// Reads available elements from the stream into the given buffer.
    ///
    /// The stream copies elements into the start of `mutableSpan`, writing at
    /// most `mutableSpan.count` elements and never more than it currently has
    /// available. On return, the first *n* elements of the buffer, where *n* is
    /// the returned count, hold the values read from the stream; any remaining
    /// elements of the buffer are left unchanged.
    ///
    /// - Parameter mutableSpan: A mutable view over the destination buffer. On
    ///   return, its first *n* elements — where *n* is the returned count —
    ///   contain the elements read from the stream.
    /// - Returns: The number of elements read into the buffer, in the range
    ///   `0...mutableSpan.count`. A value of `0` indicates that the stream has
    ///   reached its end.
    /// - Throws: A ``ReadFailure`` if the stream encounters an error while
    ///   reading.
    mutating func read(into mutableSpan: inout MutableSpan<Element>) throws(ReadFailure) -> Int
}
