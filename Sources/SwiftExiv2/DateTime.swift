import Foundation

// Export DateTime of CxxExiv2 from SwiftExiv2
// @see https://forums.swift.org/t/package-manager-exported-dependencies
@_exported import struct CxxExiv2.DateTime

extension DateTime: @retroactive Equatable {
    private static let GMT = TimeZone(secondsFromGMT: 0)!

    public static func == (lhs: DateTime, rhs: DateTime) -> Bool {
        lhs.year == rhs.year &&
        lhs.month == rhs.month &&
        lhs.day == rhs.day &&
        lhs.hour == rhs.hour &&
        lhs.minute == rhs.minute &&
        lhs.second == rhs.second &&
        lhs.offset == rhs.offset
    }

    init?(date: Date, timeZone: TimeZone?) {
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

    var date: Date? { dateComponents.date }
    var timeZone: TimeZone? { TimeZone(secondsFromGMT: offset) }

    var dateComponents: DateComponents {
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
