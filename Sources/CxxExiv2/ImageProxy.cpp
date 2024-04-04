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

Value::UniquePtr makeValueFromString(optional<String> string) {
    return string
        ? Value::UniquePtr(new AsciiValue(string.value()))
        : Value::UniquePtr(nullptr);
}

Value::UniquePtr makeValueFromRational(optional<double> rational, uint32_t denominator = 1000) {
    if (!rational) return Value::UniquePtr(nullptr);

    auto *pURationalValue = new URationalValue();
    pURationalValue->value_.push_back(URational(rational.value() * denominator, denominator));

    return Value::UniquePtr(pURationalValue);
}

Value::UniquePtr makeValueFromLocationDegrees(optional<double> locationDegrees) {
    if (!locationDegrees) return Value::UniquePtr(nullptr);

    double val = abs(locationDegrees.value());
    uint32_t deg = val; val = (val - deg) * 60;
    uint32_t min = val; val = (val - min) * 60;
    uint32_t msec = val * 1000;

    auto *pURationalValue = new URationalValue();
    pURationalValue->value_.push_back(URational(deg, 1));
    pURationalValue->value_.push_back(URational(min, 1));
    pURationalValue->value_.push_back(URational(msec, 1000));

    return Value::UniquePtr(pURationalValue);
}

Value::UniquePtr makeValueFromDateTime(optional<TimeStamp> timeStamp) {
    if (!timeStamp) return Value::UniquePtr(nullptr);

    TimeStamp ts = timeStamp.value();
    stringstream ss;

    ss << setfill('0');
    ss << setw(2) << ts.year    << ':';
    ss << setw(2) << ts.month   << ':';
    ss << setw(2) << ts.day     << ' ';
    ss << setw(2) << ts.hour    << ':';
    ss << setw(2) << ts.minute  << ':';
    ss << setw(2) << ts.second;

    return Value::UniquePtr(new AsciiValue(ss.str()));
}

Value::UniquePtr makeValueFromTimeOffset(optional<TimeStamp> timeStamp) {
    if (!timeStamp) return Value::UniquePtr(nullptr);

    TimeStamp ts = timeStamp.value();
    stringstream ss;

    ss << setfill('0');
    ss << (ts.offset_hour > 0 ? '+' : '-');
    ss << setw(2) << ts.offset_hour << ':';
    ss << setw(2) << ts.offset_minute;

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

void ImageProxy::setValueForExifKey(const String& keyName, const Value* pValue) {
    auto key = ExifKey(keyName);
    auto& exifData = _image->exifData();
    auto pos = exifData.findKey(key);
    if (pos == exifData.end()) {
        if (!pValue) return;
        exifData.add(key, pValue);
    } else if (pValue) {
        *pos = *pValue;
    } else {
        exifData.erase(pos);
    }
}

optional<double> ImageProxy::getLocationDegrees(const String& valKeyName, const String &refKeyName) const {
    auto val = getValueForExifKey(valKeyName);
    auto ref = getValueForExifKey(refKeyName);

    if (!val || !ref) return nullopt;

    float deg = val->toFloat(0);
    float min = val->toFloat(1);
    float sec = val->toFloat(2);

    return (sec/60 + min)/60 + deg;
}

optional<double> ImageProxy::getRational(const String& valKeyName, const String& refKeyName) const {
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
    auto dateTimeValue = makeValueFromDateTime(timeStamp);
    auto timeOffsetValue = makeValueFromTimeOffset(timeStamp);

    setValueForExifKey(kPhotoDateTimeOriginalKey, dateTimeValue.release());
    setValueForExifKey(kPhotoOffsetTimeOriginalKey, timeOffsetValue.release());
}

#pragma mark - GPSInfo

optional<double> ImageProxy::getLatitude() const {
    return getLocationDegrees(kGPSLatitudeKey, kGPSLatitudeRefKey);
}

void ImageProxy::setLatitude(optional<double> latitude) {
    auto latitudeVal = makeValueFromLocationDegrees(latitude);
    auto latitudeRef = latitude
        ? makeValueFromString(latitude.value() > 0 ? "N" : "S")
        : makeValueFromString(nullopt);

    setValueForExifKey(kGPSLatitudeKey, latitudeVal.release());
    setValueForExifKey(kGPSLatitudeRefKey, latitudeRef.release());
}

optional<double> ImageProxy::getLongitude() const {
    return getLocationDegrees(kGPSLongitudeKey, kGPSLongitudeRefKey);
}

void ImageProxy::setLongitude(optional<double> longitude) {
    auto longitudeVal = makeValueFromLocationDegrees(longitude);
    auto longitudeRef = longitude
        ? makeValueFromString(longitude.value() > 0 ? "E" : "W")
        : makeValueFromString(nullopt);

    setValueForExifKey(kGPSLongitudeKey, longitudeVal.release());
    setValueForExifKey(kGPSLongitudeRefKey, longitudeRef.release());
}

optional<float> ImageProxy::getAltitude() const {
    return getRational(kGPSAltitudeKey, kGPSAltitudeRefKey);
}

void ImageProxy::setAltitude(optional<float> altitude) {
    auto altitudeVal = makeValueFromRational(altitude);

    auto altitudeRef = altitude ?
        makeValueFromString(altitude.value() > 0 ? "0" : "1") :
        makeValueFromString(nullopt);

    setValueForExifKey(kGPSAltitudeKey, altitudeVal.release());
    setValueForExifKey(kGPSAltitudeRefKey, altitudeRef.release());
}
