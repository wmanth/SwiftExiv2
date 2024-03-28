#ifndef _IMAGE_HPP
#define _IMAGE_HPP

#include <string>
#include <memory>
#include <optional>

#include "../exiv2/include/exiv2/image.hpp"
#include "../exiv2/include/exiv2/value.hpp"

struct TimeStamp {
    long year;
    long month;
    long day;
    long hour;
    long minute;
    long second;
    long offset_hour;
    long offset_minute;
};

class ImageProxy {

private:
    std::shared_ptr<Exiv2::Image> _image;

private:
    Exiv2::Value::UniquePtr getValueForExifKey(const std::string& keyName) const;
    void setValueForExifKey(const std::string &keyName, const Exiv2::Value::UniquePtr& pValue);

    std::optional<double> getLocationDegrees(const std::string& valKeyName, const std::string& refKeyName) const;
    std::optional<float> getRational(const std::string& valKeyName, const std::string& refKeyName) const;

    std::optional<TimeStamp> getTimeStamp(const std::string& dateTimeKeyName, const std::string& offsetKeyName) const;

public:
    ImageProxy(const std::string& name);

public:
    void readMetadata();
    void writeMetadata();

    std::optional<TimeStamp> getDateTimeOriginal() const;
    void setDateTimeOriginal(std::optional<TimeStamp> timeStamp);
    inline void setDateTimeOriginal(TimeStamp timeStamp) { setDateTimeOriginal(std::make_optional(timeStamp)); }
    inline void removeDateTimeOriginal() { setDateTimeOriginal(std::nullopt); }

    std::optional<double> getLatitude() const;
    void setLatitude(std::optional<double> latitude);
    inline void setLatitude(double latitude) { setLatitude(std::make_optional(latitude)); }
    inline void removeLatitude() { setLatitude(std::nullopt); }

    std::optional<double> getLongitude() const;
    void setLongitude(std::optional<double> longitude);
    inline void setLongitude(double longitude) { setLongitude(std::make_optional(longitude)); }
    inline void removeLongitude() { setLongitude(std::nullopt); }

    std::optional<float> getAltitude() const;
    void setAltitude(std::optional<float> altitude);
    inline void setAltitude(float altitude) { setAltitude(std::make_optional(altitude)); }
    inline void removeAltitude() { setAltitude(std::nullopt); }
};

#endif /* _IMAGE_HPP */
