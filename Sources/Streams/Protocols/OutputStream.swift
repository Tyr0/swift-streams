
/// A type that consumes elements by writing them from a caller-supplied buffer.
///
/// An output stream is a one-directional sink for elements — such as a file, a
/// socket, or a pipe — that you fill by writing from a region of memory you
/// already own. Each element you write is handed to the stream's underlying
/// destination in order.
///
/// You write to a stream by handing a view over your buffer to the
/// ``write(_:)`` method. The stream consumes as many elements as it can accept,
/// up to the number the buffer holds, and returns the count it took. Because
/// the caller owns the source buffer and the stream cannot escape it, a stream
/// retains no storage of its own, which makes the protocol suitable for
/// performance- and latency-sensitive contexts.
///
///     let bytes = Array<UInt8>("hello".utf8)
///     let count = bytes.withUnsafeBufferPointer { pointer in
///         try destination.write(pointer.span)
///     }
///     // `count` elements of `bytes` were accepted by the stream.
///
/// A single call may accept fewer elements than the buffer holds — for example,
/// when a socket's send buffer is nearly full; write in a loop until every
/// element you intend to send has been accepted. A return value of `0`
/// indicates that the stream accepted no elements.
///
/// Because `OutputStream` does not require `Copyable`, a conforming type may be
/// non-copyable — letting it model exclusive ownership of an underlying
/// resource, such as a file descriptor — but copyable types may conform as
/// well.
@available(iOS 12.2, macOS 10.14.4, tvOS 12.2, visionOS 1.0, watchOS 5.2, *)
public protocol OutputStream<Element, WriteFailure>: ~Copyable {

    /// A type representing the stream's elements.
    associatedtype Element

    /// The type of error this stream throws when a write fails.
    associatedtype WriteFailure: Error

    /// Writes elements from the given buffer to the stream.
    ///
    /// The stream consumes elements from the start of `span`, taking at most
    /// `span.count` elements and never more than its destination can currently
    /// accept. The stream borrows `span` only for the duration of the call and
    /// does not retain a reference to the underlying buffer.
    ///
    /// - Parameter span: A view over the source buffer whose elements are
    ///   written to the stream.
    /// - Returns: The number of elements written to the stream, in the range
    ///   `0...span.count`. A value of `0` indicates that the stream accepted no
    ///   elements.
    /// - Throws: A ``WriteFailure`` if the stream encounters an error while
    ///   writing.
    mutating func write(_ span: borrowing Span<Element>) throws(WriteFailure) -> Int
}
