import Foundation
import Testing
import Numerics

@testable import SwiftExiv2

@Suite
struct SwiftExiv2Tests {
    private var temporaryDirectoryURL: URL!

    @Test(.tags(.reading))
    func failReadDateTimeOriginal() throws {
        let image = Image(url: TestResources.test1ImageURL)
        image.readMetadata()
        #expect(image.dateTimeOriginal == nil)
    }

    @Test(.tags(.reading))
    func successReadDateTimeOriginal() throws {
        let image = Image(url: TestResources.test2ImageURL)
        image.readMetadata()

        let components = try #require(image.dateTimeOriginal)
        #expect(components.year == 2022)
        #expect(components.month == 12)
        #expect(components.day == 20)
        #expect(components.hour == 15)
        #expect(components.minute == 45)
        #expect(components.second == 39)
    }

    @Test(.tags(.writing))
    func successWriteDateTime() throws {
        let tempDir = try #require(TemporaryDirectory())
        let testImageURL = try #require(tempDir.copiedResource(TestResources.test1ImageURL))

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

        let dateComponents = try #require(result.dateTimeOriginal)
        #expect(dateComponents.year == testDateComponents.year)
        #expect(dateComponents.month == testDateComponents.month)
        #expect(dateComponents.day == testDateComponents.day)
        #expect(dateComponents.hour == testDateComponents.hour)
        #expect(dateComponents.minute == testDateComponents.minute)
        #expect(dateComponents.second == testDateComponents.second)
        #expect(dateComponents.timeZone!.secondsFromGMT() == testDateComponents.timeZone!.secondsFromGMT())
    }

    @Test(.tags(.reading))
    func failToReadLatLon() throws {
        let image = Image(url: TestResources.test1ImageURL)
        image.readMetadata()

        let lat = image.latitude
        let lon = image.longitude
        let altitude = image.altitude

        #expect(lat == nil)
        #expect(lon == nil)
        #expect(altitude == nil)
    }

    @Test(.tags(.reading))
    func successToReadLatLon() throws {
        let image = Image(url: TestResources.test2ImageURL)
        image.readMetadata()

        let lat = try #require(image.latitude)
        let lon = try #require(image.longitude)
        let altitude = try #require(image.altitude)

        #expect(lat.isApproximatelyEqual(to: 30.0283, absoluteTolerance: 1/1000))
        #expect(lon.isApproximatelyEqual(to: 118.9875, absoluteTolerance: 1/1000))
        #expect(altitude.isApproximatelyEqual(to: 1158.7701, absoluteTolerance: 1/1000))
    }

    @Test(.tags(.writing))
    func successToWriteLatLon() throws {
        let tempDir = try #require(TemporaryDirectory())
        let testImageURL = try #require(tempDir.copiedResource(TestResources.test1ImageURL))

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

        let lat = try #require(image.latitude)
        let lon = try #require(image.longitude)
        let alt = try #require(image.altitude)

        #expect(lat.isApproximatelyEqual(to: testLat, absoluteTolerance: 1/1000))
        #expect(lon.isApproximatelyEqual(to: testLon, absoluteTolerance: 1/1000))
        #expect(alt.isApproximatelyEqual(to: testAlt, absoluteTolerance: 1/1000))
    }
}
