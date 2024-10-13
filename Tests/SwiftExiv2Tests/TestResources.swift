/*
  =============================================================================
  MIT License

  Copyright (c) 2024 Wolfram Manthey

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.
  =============================================================================
 */

import Foundation
import Testing

extension Tag {
    @Tag static var reading: Self
    @Tag static var writing: Self
}

struct TestResources {
    // contains no EXIF data
    static let test1ImageURL: URL! = Bundle.module.url(forResource: "test1",
                                                       withExtension: "jpg",
                                                       subdirectory: "Test Assets")

    // contains fill set of EXIF data
    static let test2ImageURL: URL! = Bundle.module.url(forResource: "test2",
                                                       withExtension: "jpg",
                                                       subdirectory: "Test Assets")
}

final class TemporaryDirectory {
    private var directory: URL

    init?() {
        directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        do { try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true) }
        catch { return nil }
    }

    deinit {
        try? FileManager.default.removeItem(at: directory)
    }

    func copiedResource(_ sourceURL: URL) -> URL? {
        let destURL = directory.appendingPathComponent(sourceURL.lastPathComponent)
        do { try FileManager.default.copyItem(at: sourceURL, to: destURL) }
        catch { return nil }
        return destURL
    }
}
