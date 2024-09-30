#ifndef _IMAGE_HPP
#define _IMAGE_HPP

#include <string>
#include <memory>
#include <optional>

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

    bool operator==(const DateTime& other) const { return
        other.year == year &&
        other.month == month &&
        other.day == day &&
        other.hour == hour &&
        other.minute == minute &&
        other.second == second &&
        other.offset == offset;
    }
};

struct Coordinate {
    double latitude;
    double longitude;

    Coordinate(double latitude, double longitude) :
        latitude(latitude),
        longitude(longitude)
    {}
};

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
    ImageProxy(const std::string& name);

public:
    void readMetadata();
    void writeMetadata();

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
