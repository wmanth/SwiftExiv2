import XCTest

@testable import Exiv2

final class SwiftExiv2Tests: XCTestCase {

    private var temporaryDirectoryURL: URL!

    private var testImageURL: URL! {
        Bundle.module.url(forResource: "test",
                        withExtension: "jpg",
                         subdirectory: "Assets")
    }

    override func setUp() {
        temporaryDirectoryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        do {
            try FileManager.default.createDirectory(at: temporaryDirectoryURL,
                           withIntermediateDirectories: true);
        } catch {
            XCTFail("could not create temporary folder")
        }
    }

    override func tearDown() {
        do {
            try FileManager.default.removeItem(at: temporaryDirectoryURL)
        } catch {
            XCTFail("could not remove temporary folder")
        }
    }

    func testFailToReadLatLon() throws {
        let image = Exiv2Image(path: testImageURL.path)
        image.readMetadata()

        let lat = image.getLatitude()
        let lon = image.getLongitude()

        XCTAssertNil(lat)
        XCTAssertNil(lon)
    }

    func testSuccessToWriteLatLon() throws {
        let destURL = temporaryDirectoryURL.appendingPathComponent(testImageURL.lastPathComponent)
        try FileManager.default.copyItem(at: testImageURL, to: destURL)
        let image = Exiv2Image(path: destURL.path)

        let testLat = NSNumber(31.22896)
        let testLon = NSNumber(121.48022)

        image.readMetadata()
        image.setLatitude(testLat)
        image.setLongitude(testLon)
        image.writeMetadata()

        let result = Exiv2Image(path: destURL.path)
        result.readMetadata()
        if let lat = image.getLatitude(),
           let lon = image.getLongitude() {
            XCTAssertEqual(lat, testLat)
            XCTAssertEqual(lon, testLon)
        } else {
            XCTFail()
        }
    }
}
