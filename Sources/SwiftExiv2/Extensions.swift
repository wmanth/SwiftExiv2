import Foundation
import CxxExiv2

extension DateComponents {
    init(timeStamp: TimeStamp) {
        let timeZone = TimeZone(secondsFromGMT: timeStamp.offset_hour * 60 * 60 + timeStamp.offset_minute * 60)
        self.init(calendar: Calendar(identifier: .iso8601),
                  timeZone: timeZone,
                  year: Int(timeStamp.year),
                  month: Int(timeStamp.month),
                  day: Int(timeStamp.day),
                  hour: Int(timeStamp.hour),
                  minute: Int(timeStamp.minute),
                  second: Int(timeStamp.second))
    }

    func toTimeStamp() -> TimeStamp? {
        guard
            let year = year,
            let month = month,
            let day = day,
            let hour = hour,
            let minute = minute,
            let second = second,
            let timeZone = timeZone
        else { return nil }

        let offset_hour = Int(timeZone.secondsFromGMT() / 3600)
        let offset_minute = Int((abs(timeZone.secondsFromGMT()) % 3600) / 60)

        return TimeStamp(year: year,
                         month: month,
                         day: day,
                         hour: hour,
                         minute: minute,
                         second: second,
                         offset_hour: offset_hour,
                         offset_minute: offset_minute)
    }
}
