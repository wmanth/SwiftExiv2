import Foundation
import Testing

@testable import SwiftExiv2

@Suite
struct DateTimeTests {

    @Test
    func createDateTime() throws {
        let dateComponents = DateComponents(calendar: Calendar(identifier: .iso8601),
                                            timeZone: TimeZone(identifier: "CET"),
                                            year: 2024,
                                            month: 3,
                                            day: 28,
                                            hour: 16,
                                            minute: 34,
                                            second: 28)

        let dateTime = try #require(DateTime(date: dateComponents.date!, timeZone: dateComponents.timeZone))
        #expect(dateTime.year   == dateComponents.year)
        #expect(dateTime.month  == dateComponents.month)
        #expect(dateTime.day    == dateComponents.day)
        #expect(dateTime.hour   == dateComponents.hour)
        #expect(dateTime.minute == dateComponents.minute)
        #expect(dateTime.second == dateComponents.second)
        #expect(dateTime.offset == 2 * 3600)
    }

    @Test
    func convertDateTimeToDateComponents() throws {
        let dateTime = DateTime(year: 2024, month: 3, day: 28, hour: 16, minute: 34, second: 28, offset: 2 * 3600)

        let dateComponents = dateTime.dateComponents
        #expect(dateComponents.year   == dateTime.year)
        #expect(dateComponents.month  == dateTime.month)
        #expect(dateComponents.day    == dateTime.day)
        #expect(dateComponents.hour   == dateTime.hour)
        #expect(dateComponents.minute == dateTime.minute)
        #expect(dateComponents.second == dateTime.second)
        #expect(dateComponents.timeZone?.secondsFromGMT() == dateTime.offset)
    }
}
