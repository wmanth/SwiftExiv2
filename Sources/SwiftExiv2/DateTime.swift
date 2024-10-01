// Export DateTime of CxxExiv2 from SwiftExiv2
// @see https://forums.swift.org/t/package-manager-exported-dependencies
@_exported import struct CxxExiv2.DateTime

import Foundation

extension DateTime {
    private static let GMT = TimeZone(secondsFromGMT: 0)!

    public init?(date: Date, timeZone: TimeZone?) {
        let timeZone = timeZone ?? Self.GMT
        let dateComponents = Calendar(identifier: .iso8601)
            .dateComponents(in: timeZone, from: date)

        guard
            let year = dateComponents.year,
            let month = dateComponents.month,
            let day = dateComponents.day,
            let hour = dateComponents.hour,
            let minute = dateComponents.minute,
            let second = dateComponents.second
        else { return nil }

        self.init()

        self.year = year
        self.month = month
        self.day = day
        self.hour = hour
        self.minute = minute
        self.second = second
        self.offset = timeZone.secondsFromGMT()
    }

    public var date: Date? { dateComponents.date }
    public var timeZone: TimeZone? { TimeZone(secondsFromGMT: offset) }

    public var dateComponents: DateComponents {
        DateComponents(
            calendar: Calendar(identifier: .iso8601),
            timeZone: timeZone,
            year: year,
            month: month,
            day: day,
            hour: hour,
            minute: minute,
            second: second
        )
    }
}
