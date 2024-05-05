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

    public var dateTimeOriginal: DateComponents? {
        set(newValue) {
            if let timeStamp = newValue?.toTimeStamp() {
                imageProxy.setDateTimeOriginal(timeStamp)
            }
            else { imageProxy.removeDateTimeOriginal() }
        }
        get {
            guard let timeStamp = imageProxy.getDateTimeOriginal().value else { return nil }
            return DateComponents(timeStamp: timeStamp)
        }
    }

    public var latitude: Double? {
        set(newValue) {
            if let latitude = newValue { imageProxy.setLatitude(latitude) }
            else { imageProxy.removeLatitude() }
        }
        get { imageProxy.getLatitude().value }
    }

    public var longitude: Double? {
        set(newValue) {
            if let longitude = newValue { imageProxy.setLongitude(longitude) }
            else { imageProxy.removeLongitude() }
        }
        get { imageProxy.getLongitude().value }
    }

    public var altitude: Float? {
        set(newValue) {
            if let altitude = newValue { imageProxy.setAltitude(altitude) }
            else { imageProxy.removeAltitude() }
        }
        get { imageProxy.getAltitude().value; }
    }
}
