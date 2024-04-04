import Foundation
import CxxExiv2

class Image {
    let url: URL
    private var imageProxy: ImageProxy

    init(url: URL) {
        self.url = url
        imageProxy = ImageProxy(std.string(url.absoluteString))
    }

    func readMetadata() { imageProxy.readMetadata() }
    func writeMetadata() { imageProxy.writeMetadata() }

    var dateTimeOriginal: DateComponents? {
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

    var latitude: Double? {
        set(newValue) {
            if let latitude = newValue { imageProxy.setLatitude(latitude) }
            else { imageProxy.removeLatitude() }
        }
        get { imageProxy.getLatitude().value }
    }

    var longitude: Double? {
        set(newValue) {
            if let longitude = newValue { imageProxy.setLongitude(longitude) }
            else { imageProxy.removeLongitude() }
        }
        get { imageProxy.getLongitude().value }
    }

    var altitude: Float? {
        set(newValue) {
            if let altitude = newValue { imageProxy.setAltitude(altitude) }
            else { imageProxy.removeAltitude() }
        }
        get { imageProxy.getAltitude().value; }
    }
}
