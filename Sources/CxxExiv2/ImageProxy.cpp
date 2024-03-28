#include "ImageProxy.hpp"

using namespace std;
using namespace Exiv2;

using String = std::string;

static const String kImageDateTimeKey    = "Exif.Image.DateTime";

static const String kPhotoOffsetTimeKey           = "Exif.Photo.OffsetTime";
static const String kPhotoDateTimeOriginalKey     = "Exif.Photo.DateTimeOriginal";
static const String kPhotoDateTimeDigitizedKey    = "Exif.Photo.DateTimeDigitized";
static const String kPhotoOffsetTimeOriginalKey   = "Exif.Photo.OffsetTimeOriginal";
static const String kPhotoOffsetTimeDigitizedKey  = "Exif.Photo.OffsetTimeDigitized";

static const String kGPSLatitudeKey      = "Exif.GPSInfo.GPSLatitude";
static const String kGPSLatitudeRefKey   = "Exif.GPSInfo.GPSLatitudeRef";
static const String kGPSLongitudeKey     = "Exif.GPSInfo.GPSLongitude";
static const String kGPSLongitudeRefKey  = "Exif.GPSInfo.GPSLongitudeRef";
static const String kGPSAltitudeKey      = "Exif.GPSInfo.GPSAltitude";
static const String kGPSAltitudeRefKey   = "Exif.GPSInfo.GPSAltitudeRef";

Value::UniquePtr makeValueFromRational(uint32_t value, uint32_t denominator) {
    auto *pURationalValue = new URationalValue();
    pURationalValue->value_.push_back(URational(value, denominator));

    return Value::UniquePtr(pURationalValue);
}

Value::UniquePtr makeValueFromLocationDegrees(double locationDegrees) {
    double val = abs(locationDegrees);
    uint32_t deg = val; val = (val - deg) * 60;
    uint32_t min = val; val = (val - min) * 60;
    uint32_t msec = val * 1000;

    auto *pURationalValue = new URationalValue();
    pURationalValue->value_.push_back(URational(deg, 1));
    pURationalValue->value_.push_back(URational(min, 1));
    pURationalValue->value_.push_back(URational(msec, 1000));

    return Value::UniquePtr(pURationalValue);
}

Value::UniquePtr makeValueFromDateTime(const TimeStamp& timeStamp) {
    stringstream ss;

    ss << setfill('0');
    ss << setw(2) << timeStamp.year     << ':';
    ss << setw(2) << timeStamp.month    << ':';
    ss << setw(2) << timeStamp.day      << ' ';
    ss << setw(2) << timeStamp.hour     << ':';
    ss << setw(2) << timeStamp.minute   << ':';
    ss << setw(2) << timeStamp.second;

    return Value::UniquePtr(new AsciiValue(ss.str()));
}

Value::UniquePtr makeValueFromTimeOffset(const TimeStamp& timeStamp) {
    stringstream ss;

    ss << setfill('0');
    ss << (timeStamp.offset_hour > 0 ? '+' : '-');
    ss << setw(2) << timeStamp.offset_hour << ':';
    ss << setw(2) << timeStamp.offset_minute;

    return Value::UniquePtr(new AsciiValue(ss.str()));
}

ImageProxy::ImageProxy(const String& name) {
    _image = ImageFactory::open(name);
}

void ImageProxy::readMetadata() {
    _image->readMetadata();
}

void ImageProxy::writeMetadata() {
    _image->writeMetadata();
}

Value::UniquePtr ImageProxy::getValueForExifKey(const String& keyName) const {
    auto key = ExifKey(keyName);
    auto exifData = _image->exifData();
    auto pos = exifData.findKey(key);

    return pos == exifData.end() ? nullptr : pos->getValue();
}

void ImageProxy::setValueForExifKey(const String& keyName, const Value::UniquePtr& value) {
    auto key = ExifKey(keyName);
    auto& exifData = _image->exifData();
    auto pos = exifData.findKey(key);
    if (pos == exifData.end()) {
        if (!value) return;
        exifData.add(key, value.get());
    } else if (value) {
        *pos = *value;
    } else {
        exifData.erase(pos);
    }
}

optional<double> ImageProxy::getLocationDegrees(const String& valKeyName, const String &refKeyName) const {
    auto val = getValueForExifKey(valKeyName);
    auto ref = getValueForExifKey(refKeyName);

    if (!val || !ref) return std::nullopt;

    float deg = val->toFloat(0);
    float min = val->toFloat(1);
    float sec = val->toFloat(2);

    return (sec/60 + min)/60 + deg;
}

optional<float> ImageProxy::getRational(const String& valKeyName, const String& refKeyName) const {
    auto val = getValueForExifKey(valKeyName);
    auto ref = getValueForExifKey(refKeyName);

    if (!val || !ref) return std::nullopt;

    bool isNegative = ref->toUint32() == 1;
    return val->toFloat() * (isNegative ? -1 : 1);
}

optional<TimeStamp> ImageProxy::getTimeStamp(const String& dateTimeKeyName, const String& offsetKeyName) const {
    auto dateTimeValue = getValueForExifKey(dateTimeKeyName);
    auto timeZoneValue = getValueForExifKey(offsetKeyName);

    if (!dateTimeValue) return std::nullopt;

    String dateTimeString = dateTimeValue->toString();
    String timeZoneString = timeZoneValue ? timeZoneValue->toString() : "+00:00";

    TimeStamp timeStamp;
    timeStamp.year   = stoi(dateTimeString.substr(0, 4));
    timeStamp.month  = stoi(dateTimeString.substr(5, 2));
    timeStamp.day    = stoi(dateTimeString.substr(8, 2));
    timeStamp.hour   = stoi(dateTimeString.substr(11, 2));
    timeStamp.minute = stoi(dateTimeString.substr(14, 2));
    timeStamp.second = stoi(dateTimeString.substr(17, 2));

    timeStamp.offset_hour   = stoi(timeZoneString.substr(0, 3));
    timeStamp.offset_minute = stoi(timeZoneString.substr(4, 2));;

    return timeStamp;
}


#pragma mark - Photo

optional<TimeStamp> ImageProxy::getDateTimeOriginal() const {
    return getTimeStamp(kPhotoDateTimeOriginalKey, kPhotoOffsetTimeOriginalKey);
}

void ImageProxy::setDateTimeOriginal(optional<TimeStamp> timeStamp) {
    auto dateTimeValue = timeStamp.has_value()
        ? makeValueFromDateTime(timeStamp.value())
        : Value::UniquePtr(nullptr);
    auto timeOffsetValue = timeStamp.has_value()
        ? makeValueFromTimeOffset(timeStamp.value())
        : Value::UniquePtr(nullptr);

    setValueForExifKey(kPhotoDateTimeOriginalKey, dateTimeValue);
    setValueForExifKey(kPhotoOffsetTimeOriginalKey, timeOffsetValue);
}

#pragma mark - GPSInfo

optional<double> ImageProxy::getLatitude() const {
    return getLocationDegrees(kGPSLatitudeKey, kGPSLatitudeRefKey);
}

void ImageProxy::setLatitude(optional<double> latitude) {
    auto val = latitude
        ? makeValueFromLocationDegrees(latitude.value())
        : Value::UniquePtr(nullptr);
    auto ref = latitude
        ? Value::UniquePtr(new AsciiValue(latitude.value() > 0 ? "N" : "S"))
        : Value::UniquePtr(nullptr);

    setValueForExifKey(kGPSLatitudeKey, val);
    setValueForExifKey(kGPSLatitudeRefKey, ref);
}

optional<double> ImageProxy::getLongitude() const {
    return getLocationDegrees(kGPSLongitudeKey, kGPSLongitudeRefKey);
}

void ImageProxy::setLongitude(optional<double> longitude) {
    auto val = longitude
        ? makeValueFromLocationDegrees(longitude.value())
        : Value::UniquePtr(nullptr);
    auto ref = longitude
        ? Value::UniquePtr(new AsciiValue(longitude.value() > 0 ? "E" : "W"))
        : Value::UniquePtr(nullptr);

    setValueForExifKey(kGPSLongitudeKey, val);
    setValueForExifKey(kGPSLongitudeRefKey, ref);
}

optional<float> ImageProxy::getAltitude() const {
    return getRational(kGPSAltitudeKey, kGPSAltitudeRefKey);
}

void ImageProxy::setAltitude(optional<float> altitude) {
    uint32_t denominator = 100;

    auto altitudeVal = altitude.has_value()
        ? makeValueFromRational(altitude.value() * denominator, denominator)
        : Value::UniquePtr(nullptr);

    auto altitudeRef = altitude.has_value()
        ? Value::UniquePtr(new AsciiValue(altitude.value() > 0 ? "0" : "1"))
        : Value::UniquePtr(nullptr);

    setValueForExifKey(kGPSAltitudeKey, altitudeVal);
    setValueForExifKey(kGPSAltitudeRefKey, altitudeRef);
}
