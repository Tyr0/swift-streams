//
//  RangeReplaceableCollection+Streams.swift
//  swift-streams
//
//  Created by Tyler Calderone on 6/25/26.
//

@available(iOS 12.2, macOS 10.14.4, tvOS 12.2, visionOS 1.0, watchOS 5.2, *)
extension RangeReplaceableCollection where Self: InputStream {

    @inlinable
    public mutating func read(into mutableSpan: inout MutableSpan<Element>) throws(Never) -> Int {
        let count = Swift.min(mutableSpan.count, self.count)

        guard count > 0 else { return 0 }

        let startIndex = self.startIndex
        let startIndexOffsetByCount = self.index(startIndex, offsetBy: count)

        mutableSpan.withUnsafeMutableBufferPointer { unsafeMutableBufferPointer in
            // optimized path: copy contiguous region
            if self.withContiguousStorageIfAvailable({ unsafeBufferPointer in
                _ = unsafeMutableBufferPointer.update(fromContentsOf: UnsafeBufferPointer(rebasing: unsafeBufferPointer[..<count]))
            }) != nil { return }

            // fallback path: discontiguous region
            _ = unsafeMutableBufferPointer.update(from: self[startIndex..<startIndexOffsetByCount])
        }

        self.removeSubrange(startIndex..<startIndexOffsetByCount)

        return count
    }
}

@available(iOS 12.2, macOS 10.14.4, tvOS 12.2, visionOS 1.0, watchOS 5.2, *)
extension RangeReplaceableCollection where Self: OutputStream {

    @inlinable
    public mutating func write(_ span: borrowing Span<Element>) throws(Never) -> Int {
        return span.withUnsafeBufferPointer { unsafeBufferPointer in
            self.append(contentsOf: unsafeBufferPointer)

            return unsafeBufferPointer.count
        }
    }
}
