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
