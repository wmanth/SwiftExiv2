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
