import XCTest

@testable import SwiftExiv2

final class SwiftExiv2Tests: XCTestCase {

    private var temporaryDirectoryURL: URL!

    // contains no EXIF data
    private var test1ImageURL: URL! {
        Bundle.module.url(forResource: "test1",
                        withExtension: "jpg",
                         subdirectory: "Test Assets")
    }

    // contains fill set of EXIF data
    private var test2ImageURL: URL! {
        Bundle.module.url(forResource: "test2",
                        withExtension: "jpg",
                         subdirectory: "Test Assets")
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

    func temporaryCopiedResource(_ sourceURL: URL) throws -> URL {
        let destURL = temporaryDirectoryURL.appendingPathComponent(sourceURL.lastPathComponent)
        try FileManager.default.copyItem(at: sourceURL, to: destURL)
        return destURL
    }

    func testFailReadDateTimeOriginal() throws {
        let image = Image(url: test1ImageURL)
        image.readMetadata()
        XCTAssertNil(image.dateTimeOriginal)
    }

    func testSuccessReadDateTimeOriginal() throws {
        let image = Image(url: test2ImageURL)
        image.readMetadata()
        if let components = image.dateTimeOriginal {
            XCTAssertEqual(components.year, 2022)
            XCTAssertEqual(components.month, 12)
            XCTAssertEqual(components.day, 20)
            XCTAssertEqual(components.hour, 15)
            XCTAssertEqual(components.minute, 45)
            XCTAssertEqual(components.second, 39)
        }
        else {
            XCTFail()
        }
    }

    func testSuccessWriteDateTime() throws {
        let testImageURL = try self.temporaryCopiedResource(test1ImageURL)

        let image = Image(url: testImageURL)
        image.readMetadata()
        let testDateComponents = DateComponents(
            calendar: Calendar(identifier: .iso8601),
            timeZone: TimeZone(identifier: "CET"),
            year: 2022,
            month: 3,
            day: 28,
            hour: 9,
            minute: 32,
            second: 14)
        image.dateTimeOriginal = testDateComponents
        image.writeMetadata()

        let result = Image(url: testImageURL)
        result.readMetadata()
        if let dateComponents = result.dateTimeOriginal {
            XCTAssertEqual(dateComponents.year,   testDateComponents.year)
            XCTAssertEqual(dateComponents.month,  testDateComponents.month)
            XCTAssertEqual(dateComponents.day,    testDateComponents.day)
            XCTAssertEqual(dateComponents.hour,   testDateComponents.hour)
            XCTAssertEqual(dateComponents.minute, testDateComponents.minute)
            XCTAssertEqual(dateComponents.second, testDateComponents.second)
            XCTAssertEqual(dateComponents.timeZone!.secondsFromGMT(), testDateComponents.timeZone!.secondsFromGMT())
        }
        else {
            XCTFail()
        }
    }

    func testFailToReadLatLon() throws {
        let image = Image(url: test1ImageURL)
        image.readMetadata()

        let lat = image.latitude
        let lon = image.longitude
        let altitude = image.altitude

        XCTAssertNil(lat)
        XCTAssertNil(lon)
        XCTAssertNil(altitude)
    }

    func testSuccessToReadLatLon() throws {
        let image = Image(url: test2ImageURL)
        image.readMetadata()

        if let lat = image.latitude,
           let lon = image.longitude,
           let altitude = image.altitude {

            XCTAssertEqual(lat, 30.0283, accuracy: 0.0001)
            XCTAssertEqual(lon, 118.9875, accuracy: 0.0001)
            XCTAssertEqual(altitude, 1158.7701, accuracy: 0.0001)
        }
        else {
            XCTFail()
        }
    }

    func testSuccessToWriteLatLon() throws {
        let testImageURL = try self.temporaryCopiedResource(test1ImageURL)
        let image = Image(url: testImageURL)

        let testLat: Double = 31.22896
        let testLon: Double = 121.48022
        let testAlt: Float = 1683.24

        image.readMetadata()
        image.latitude = testLat
        image.longitude = testLon
        image.altitude = testAlt
        image.writeMetadata()

        let result = Image(url: testImageURL)
        result.readMetadata()
        if let lat = image.latitude,
           let lon = image.longitude,
           let alt = image.altitude {
            XCTAssertEqual(lat, testLat, accuracy: 1/1000)
            XCTAssertEqual(lon, testLon, accuracy: 1/1000)
            XCTAssertEqual(alt, testAlt, accuracy: 1/1000)

        } else {
            XCTFail()
        }
    }
}
