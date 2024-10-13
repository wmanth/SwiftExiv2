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
