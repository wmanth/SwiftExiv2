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

#ifndef _IMAGE_HPP
#define _IMAGE_HPP

#include <string>
#include <memory>
#include <optional>
#include <swift/bridging>

#include "../exiv2/include/exiv2/image.hpp"
#include "../exiv2/include/exiv2/value.hpp"

struct DateTime {
    long year;
    long month;
    long day;
    long hour;
    long minute;
    long second;
    long offset;
} SWIFT_CONFORMS_TO_PROTOCOL(Swift.Equatable);

#pragma mark -

struct Coordinate {
    double latitude;
    double longitude;

    Coordinate(double latitude, double longitude) :
        latitude(latitude),
        longitude(longitude)
    {}
} SWIFT_CONFORMS_TO_PROTOCOL(Swift.Equatable);

#pragma mark -

struct Error {
private:
    Exiv2::ErrorCode _code;
    std::string _message;

public:
    Exiv2::ErrorCode getCode() const SWIFT_COMPUTED_PROPERTY { return _code; }
    std::string getMessage() const SWIFT_COMPUTED_PROPERTY { return _message; }

    Error() : _code(Exiv2::ErrorCode::kerSuccess), _message(std::string()) {}
    Error(const Exiv2::Error& error) : _code(error.code()), _message(error.what()) {}
};

#pragma mark -

class ImageProxy {

private:
    std::shared_ptr<Exiv2::Image> _image;

private:
    Exiv2::Value::UniquePtr getValueForExifKey(const std::string& keyName) const;
    void setValueForExifKey(const std::string &keyName, const Exiv2::Value* pValue);

    std::optional<double> getLocationDegrees(const std::string& valKeyName) const;
    std::optional<double> getRational(const std::string& valKeyName, const std::string& refKeyName) const;

    std::optional<DateTime> getDateTime(const std::string& dateTimeKeyName, const std::string& offsetKeyName) const;

public:
    ImageProxy(const std::string& name, Error& error);

public:
    void readMetadata(Error& error);
    void writeMetadata(Error& error);

    std::optional<DateTime> getDateTimeOriginal() const;
    void setDateTimeOriginal(std::optional<DateTime> dateTime);
    inline void setDateTimeOriginal(DateTime dateTime) { setDateTimeOriginal(std::make_optional(dateTime)); }
    inline void removeDateTimeOriginal() { setDateTimeOriginal(std::nullopt); }

    std::optional<Coordinate> getCoordinate() const;
    void setCoordinate(std::optional<Coordinate> coordinate);
    inline void setCoordinate(Coordinate coordinate) { setCoordinate(std::make_optional(coordinate)); }
    inline void removeCoordinate() { setCoordinate(std::nullopt); }

    std::optional<float> getAltitude() const;
    void setAltitude(std::optional<float> altitude);
    inline void setAltitude(float altitude) { setAltitude(std::make_optional(altitude)); }
    inline void removeAltitude() { setAltitude(std::nullopt); }
};

#endif /* _IMAGE_HPP */
