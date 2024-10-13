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
import CxxExiv2

public class Image {
    public let url: URL
    private var imageProxy: ImageProxy

    struct Error: Swift.Error {
        let message: String

        init(message: std.string) {
            self.message = String(message)
        }
    }

    public init(url: URL) throws {
        var error = CxxExiv2.Error()
        let imageProxy = ImageProxy(std.string(url.path), &error)

        if error.code != .kerSuccess {
            throw Error(message: error.message)
        }

        self.url = url
        self.imageProxy = imageProxy
    }

    public func readMetadata() throws {
        var error = CxxExiv2.Error()
        imageProxy.readMetadata(&error)

        if error.code != .kerSuccess {
            throw Error(message: error.message)
        }
    }

    public func writeMetadata() throws {
        var error = CxxExiv2.Error()
        imageProxy.writeMetadata(&error)

        if error.code != .kerSuccess {
            throw Error(message: error.message)
        }
    }

    public var dateTimeOriginal: DateTime? {
        set(newValue) {
            if let timeStamp = newValue {
                imageProxy.setDateTimeOriginal(timeStamp)
            }
            else { imageProxy.removeDateTimeOriginal() }
        }
        get { imageProxy.getDateTimeOriginal().value }
    }

    public var coordinate: Coordinate? {
        set(newValue) {
            if let coordinate = newValue { imageProxy.setCoordinate(coordinate) }
            else { imageProxy.removeCoordinate() }
        }
        get { imageProxy.getCoordinate().value }
    }

    public var altitude: Float? {
        set(newValue) {
            if let altitude = newValue { imageProxy.setAltitude(altitude) }
            else { imageProxy.removeAltitude() }
        }
        get { imageProxy.getAltitude().value; }
    }
}
