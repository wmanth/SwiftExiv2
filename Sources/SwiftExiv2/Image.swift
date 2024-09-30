import Foundation
import CxxExiv2

public class Image {
    public let url: URL
    private var imageProxy: ImageProxy

    public init(url: URL) {
        self.url = url
        imageProxy = ImageProxy(std.string(url.path))
    }

    public func readMetadata() { imageProxy.readMetadata() }
    public func writeMetadata() { imageProxy.writeMetadata() }

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
