
import Testing

@testable import Streams

@Suite
struct ArrayStreamTests {

    private enum Fixtures {

        static let initialValues: Array<Array<Int>> = [
            [],
            [0],
            [0, 1, 2, 3],
        ]
    }

    @Suite
    struct InputStreamTests {

        @Test(arguments: Fixtures.initialValues)
        func testRead_DequeuesInOrder(initialValues: Array<Int>) async throws {
            var stream = initialValues

            let (count, buffer) = self.read(from: &stream, bufferSize: initialValues.count)

            #expect(buffer == initialValues)
            #expect(count == initialValues.count)
            #expect(stream.isEmpty)
        }

        @Test
        func testRead_FillsDestinationWhenItIsSmallerThanStream() async throws {
            var stream = [10, 20, 30, 40, 50]

            let (count, buffer) = self.read(from: &stream, bufferSize: 2)

            #expect(count == 2)
            #expect(buffer == [10, 20])
            #expect(stream == [30, 40, 50])
        }

        @Test
        func testRead_PrependsDestinationWhenItIsSmallerThanStream() async throws {
            var stream = [10, 20]

            let (count, buffer) = self.read(from: &stream, bufferSize: 4, repeating: -1)

            #expect(count == 2)
            #expect(buffer == [10, 20, -1, -1])
            #expect(stream.isEmpty)
        }

        @Test
        func testSequentialReadsConsumeStreamInFIFOOrder() async throws {
            var stream = [10, 20, 30, 40, 50]

            let first = self.read(from: &stream, bufferSize: 2)
            #expect(first.count == 2)
            #expect(first.buffer == [10, 20])
            #expect(stream == [30, 40, 50])

            let second = self.read(from: &stream, bufferSize: 2)
            #expect(second.count == 2)
            #expect(second.buffer == [30, 40])
            #expect(stream == [50])
        }

        @Test
        func testReadFromEmptyStreamReturnsZeroAndLeavesBufferUnchanged() async throws {
            var stream = Array<Int>()

            let (count, buffer) = self.read(from: &stream, bufferSize: 2, repeating: -1)

            #expect(count == 0)
            #expect(buffer == [-1, -1])
            #expect(stream.isEmpty)
        }

        @Test
        func testReadReturnsZeroOnceStreamIsExhausted() async throws {
            var stream = [10, 20]

            let drained = self.read(from: &stream, bufferSize: 2)
            #expect(drained.count == 2)
            #expect(stream.isEmpty)

            let (count, buffer) = self.read(from: &stream, bufferSize: 2, repeating: -1)
            #expect(count == 0)
            #expect(buffer == [-1, -1])
        }

        // MARK: - Private Functions

        /// Reads from `stream` into a freshly allocated buffer of `bufferSize`
        /// (pre-filled with `fill`), returning the count read alongside the
        /// buffer's contents after the read.
        private func read<Element>(from stream: inout Array<Element>, bufferSize: Int, repeating repeatedValue: Element = 0) -> (count: Int, buffer: Array<Element>) where Element: ExpressibleByIntegerLiteral {
            var buffer = Array<Element>(repeating: repeatedValue, count: bufferSize)
            let count = buffer.withUnsafeMutableBufferPointer { unsafeMutableBufferPointer in
                var mutableSpan = unsafeMutableBufferPointer.mutableSpan
                return stream.read(into: &mutableSpan)
            }

            return (count, buffer)
        }
    }

    @Suite
    struct OutputStreamTests {

        @Test(arguments: Fixtures.initialValues)
        func testWrite_EnqueuesInOrder(inputValues: Array<Int>) async throws {
            var outputStream = Array<Int>()

            let writeCount = inputValues.withUnsafeBufferPointer { unsafeBufferPointer in
                outputStream.write(unsafeBufferPointer.span)
            }

            #expect(outputStream == inputValues)
            #expect(writeCount == inputValues.count)
        }

        @Test(arguments: Fixtures.initialValues)
        func testWrite_AppendsToTailOfNonEmptyStream(inputValues: Array<Int>) async throws {
            var outputStream = Array<Int>([1, 2])

            let writeCount = inputValues.withUnsafeBufferPointer { unsafeBufferPointer in
                outputStream.write(unsafeBufferPointer.span)
            }

            #expect(outputStream == [1, 2] + inputValues)
            #expect(writeCount == inputValues.count)
        }
    }
}
