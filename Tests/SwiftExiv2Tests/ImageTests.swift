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
import Numerics

@testable import SwiftExiv2

@Suite
struct SwiftExiv2Tests {
    private var temporaryDirectoryURL: URL!

    @Test(.tags(.reading))
    func failToReadFile() throws {
        #expect(throws: Image.Error.self) {
            let _ = try Image(url: URL(fileURLWithPath: String()))
        }
    }

    @Test(.tags(.reading))
    func successToReadFile() throws {
        #expect(throws: Never.self) {
            let _ = try Image(url: TestResources.test1ImageURL)
            let _ = try Image(url: TestResources.test2ImageURL)
        }
    }

    @Test(.tags(.reading))
    func failReadDateTimeOriginal() throws {
        let image = try Image(url: TestResources.test1ImageURL)
        try image.readMetadata()
        #expect(image.dateTimeOriginal == nil)
    }

    @Test(.tags(.reading))
    func successReadDateTimeOriginal() throws {
        let image = try Image(url: TestResources.test2ImageURL)
        try image.readMetadata()

        let dateTime = try #require(image.dateTimeOriginal)
        #expect(dateTime.year == 2022)
        #expect(dateTime.month == 12)
        #expect(dateTime.day == 20)
        #expect(dateTime.hour == 15)
        #expect(dateTime.minute == 45)
        #expect(dateTime.second == 39)
        #expect(dateTime.offset == 8 * 3600)
    }

    @Test(.tags(.writing))
    func successWriteDateTime() throws {
        let tempDir = try #require(TemporaryDirectory())
        let testImageURL = try #require(tempDir.copiedResource(TestResources.test1ImageURL))

        let image = try Image(url: testImageURL)
        try image.readMetadata()

        let testDateTime = DateTime(
            year: 2022,
            month: 3,
            day: 28,
            hour: 9,
            minute: 32,
            second: 14,
            offset: 2 * 3600)
        image.dateTimeOriginal = testDateTime
        try image.writeMetadata()

        let result = try Image(url: testImageURL)
        try result.readMetadata()

        let dateTime = try #require(result.dateTimeOriginal)
        #expect(dateTime == testDateTime)
    }

    @Test(.tags(.reading))
    func failToReadLatLon() throws {
        let image = try Image(url: TestResources.test1ImageURL)
        try image.readMetadata()

        #expect(image.coordinate == nil)
        #expect(image.altitude == nil)
    }

    @Test(.tags(.reading))
    func successToReadCoordinate() throws {
        let image = try Image(url: TestResources.test2ImageURL)
        try image.readMetadata()

        let coordinate = try #require(image.coordinate)
        let altitude = try #require(image.altitude)

        #expect(coordinate.latitude.isApproximatelyEqual(to: 30.0283, absoluteTolerance: 1/10000))
        #expect(coordinate.longitude.isApproximatelyEqual(to: 118.9875, absoluteTolerance: 1/10000))
        #expect(altitude.isApproximatelyEqual(to: 1158.7701, absoluteTolerance: 1/1000))
    }

    @Test(.tags(.writing), arguments: [
        Coordinate(31.22896, 121.48022),
        Coordinate(-31.22896, -121.48022)]
    )
    func successToWriteCoordinate(testCoordinate: Coordinate) throws {
        let tempDir = try #require(TemporaryDirectory())
        let testImageURL = try #require(tempDir.copiedResource(TestResources.test1ImageURL))

        let image = try Image(url: testImageURL)
        let testAlt: Float = 1683.24

        try image.readMetadata()
        image.coordinate = testCoordinate
        image.altitude = testAlt
        try image.writeMetadata()

        let result = try Image(url: testImageURL)
        try result.readMetadata()

        let coordinate = try #require(image.coordinate)
        let altitude = try #require(image.altitude)

        #expect(coordinate.latitude.isApproximatelyEqual(to: testCoordinate.latitude, absoluteTolerance: 1/10000))
        #expect(coordinate.longitude.isApproximatelyEqual(to: testCoordinate.longitude, absoluteTolerance: 1/10000))
        #expect(altitude.isApproximatelyEqual(to: testAlt, absoluteTolerance: 1/1000))
    }
}
