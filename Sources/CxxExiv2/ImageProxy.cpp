#include "ImageProxy.hpp"

#include <iostream>

using namespace std;
using namespace Exiv2;

using String = std::string;

static const String kImageDateTimeKey    = "Exif.Image.DateTime";

static const String kPhotoOffsetTimeKey           = "Exif.Photo.OffsetTime";
static const String kPhotoDateTimeOriginalKey     = "Exif.Photo.DateTimeOriginal";
static const String kPhotoDateTimeDigitizedKey    = "Exif.Photo.DateTimeDigitized";
static const String kPhotoOffsetTimeOriginalKey   = "Exif.Photo.OffsetTimeOriginal";
static const String kPhotoOffsetTimeDigitizedKey  = "Exif.Photo.OffsetTimeDigitized";

static const String kGPSLatitudeKey         = "Exif.GPSInfo.GPSLatitude";
static const String kGPSLatitudeRefKey      = "Exif.GPSInfo.GPSLatitudeRef";
static const String kGPSLongitudeKey        = "Exif.GPSInfo.GPSLongitude";
static const String kGPSLongitudeRefKey     = "Exif.GPSInfo.GPSLongitudeRef";
static const String kGPSAltitudeKey         = "Exif.GPSInfo.GPSAltitude";
static const String kGPSAltitudeRefKey      = "Exif.GPSInfo.GPSAltitudeRef";

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

Value::UniquePtr makeValueFromDateTime(optional<DateTime> opt_dateTime) {
    if (!opt_dateTime) return Value::UniquePtr(nullptr);

    DateTime dateTime = opt_dateTime.value();
    stringstream ss;

    ss << setfill('0');
    ss << setw(2) << dateTime.year    << ':';
    ss << setw(2) << dateTime.month   << ':';
    ss << setw(2) << dateTime.day     << ' ';
    ss << setw(2) << dateTime.hour    << ':';
    ss << setw(2) << dateTime.minute  << ':';
    ss << setw(2) << dateTime.second;

    return Value::UniquePtr(new AsciiValue(ss.str()));
}

Value::UniquePtr makeValueFromTimeOffset(optional<DateTime> opt_dateTime) {
    if (!opt_dateTime) return Value::UniquePtr(nullptr);

    DateTime dateTime = opt_dateTime.value();
    long offset_hours = dateTime.offset / 3600;
    long offset_minutes = (dateTime.offset - offset_hours * 3600) / 60;

    stringstream ss;

    ss << setfill('0');
    ss << (dateTime.offset > 0 ? '+' : '-');
    ss << setw(2) << offset_hours << ':';
    ss << setw(2) << offset_minutes;

    return Value::UniquePtr(new AsciiValue(ss.str()));
}

ImageProxy::ImageProxy(const String& name, ::Error& error) : _image(nullptr) {
    try {
        _image = ImageFactory::open(name);
    } catch (const Exiv2::Error& e) {
        error = ::Error(e);
    }
}

void ImageProxy::readMetadata(::Error& error) {
    if (!_image) {
        error = ::Error(Exiv2::Error(ErrorCode::kerCallFailed));
        return;
    }
    try {
        _image->readMetadata();
    } catch (const Exiv2::Error& e) {
        error = ::Error(e);
    }
}

void ImageProxy::writeMetadata(::Error& error) {
    if (!_image) {
        error = ::Error(Exiv2::Error(ErrorCode::kerCallFailed));
        return;
    }
    try {
        _image->writeMetadata();
    } catch (const Exiv2::Error& e) {
        error = ::Error(e);
    }
}

Value::UniquePtr ImageProxy::getValueForExifKey(const String& keyName) const {
    if (!_image) return Value::UniquePtr(nullptr);

    auto key = ExifKey(keyName);
    auto exifData = _image->exifData();
    auto pos = exifData.findKey(key);

    return pos == exifData.end() ? nullptr : pos->getValue();
}

void ImageProxy::setValueForExifKey(const String& keyName, const Value* pValue) {
    if (!_image) return;

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

optional<double> ImageProxy::getLocationDegrees(const String& valKeyName) const {
    auto val = getValueForExifKey(valKeyName);

    if (!val) return nullopt;

    double deg = val->toFloat(0);
    double min = val->toFloat(1);
    double sec = val->toFloat(2);

    return (sec/60 + min)/60 + deg;
}

optional<double> ImageProxy::getRational(const String& valKeyName, const String& refKeyName) const {
    auto val = getValueForExifKey(valKeyName);
    auto ref = getValueForExifKey(refKeyName);

    if (!val || !ref) return nullopt;

    bool isNegative = ref->toUint32() == 1;
    return val->toFloat() * (isNegative ? -1 : 1);
}

optional<DateTime> ImageProxy::getDateTime(const String& dateTimeKeyName, const String& offsetKeyName) const {
    auto dateTimeValue = getValueForExifKey(dateTimeKeyName);
    auto timeZoneValue = getValueForExifKey(offsetKeyName);

    if (!dateTimeValue) return nullopt;

    String dateTimeString = dateTimeValue->toString();
    String timeZoneString = timeZoneValue ? timeZoneValue->toString() : "+00:00";

    DateTime dateTime;
    dateTime.year   = stoi(dateTimeString.substr(0, 4));
    dateTime.month  = stoi(dateTimeString.substr(5, 2));
    dateTime.day    = stoi(dateTimeString.substr(8, 2));
    dateTime.hour   = stoi(dateTimeString.substr(11, 2));
    dateTime.minute = stoi(dateTimeString.substr(14, 2));
    dateTime.second = stoi(dateTimeString.substr(17, 2));

    int offset_hour   = stoi(timeZoneString.substr(0, 3));
    int offset_minute = stoi(timeZoneString.substr(4, 2));
    dateTime.offset = offset_hour * 3600 + offset_minute * 60;

    return dateTime;
}


#pragma mark - Photo

optional<DateTime> ImageProxy::getDateTimeOriginal() const {
    return getDateTime(kPhotoDateTimeOriginalKey, kPhotoOffsetTimeOriginalKey);
}

void ImageProxy::setDateTimeOriginal(optional<DateTime> dateTime) {
    auto dateTimeValue = makeValueFromDateTime(dateTime);
    auto timeOffsetValue = makeValueFromTimeOffset(dateTime);

    setValueForExifKey(kPhotoDateTimeOriginalKey, dateTimeValue.release());
    setValueForExifKey(kPhotoOffsetTimeOriginalKey, timeOffsetValue.release());
}

#pragma mark - GPSInfo

optional<Coordinate> ImageProxy::getCoordinate() const {
    auto latVal = getLocationDegrees(kGPSLatitudeKey);
    auto latRef = getValueForExifKey(kGPSLatitudeRefKey);
    auto lonVal = getLocationDegrees(kGPSLongitudeKey);
    auto lonRef = getValueForExifKey(kGPSLongitudeRefKey);

    if (!latVal || !latRef || !lonVal || !lonRef) return nullopt;

    int latSign = latRef->toString() == "N" ? 1 : -1;
    int lonSign = lonRef->toString() == "E" ? 1 : -1;

    double latitude = latSign * latVal.value();
    double longitude = lonSign * lonVal.value();

    return Coordinate(latitude, longitude);
}

void ImageProxy::setCoordinate(optional<Coordinate> opt_coord) {
    if (!opt_coord) {
        setValueForExifKey(kGPSLatitudeKey, nullptr);
        setValueForExifKey(kGPSLatitudeRefKey, nullptr);
        setValueForExifKey(kGPSLongitudeKey, nullptr);
        setValueForExifKey(kGPSLongitudeRefKey, nullptr);
    }
    else {
        Coordinate coord = opt_coord.value();
        auto latVal = makeValueFromLocationDegrees(coord.latitude);
        auto latRef = makeValueFromString(coord.latitude > 0 ? "N" : "S");
        auto lonVal = makeValueFromLocationDegrees(coord.longitude);
        auto lonRef = makeValueFromString(coord.latitude > 0 ? "E" : "W");

        setValueForExifKey(kGPSLatitudeKey, latVal.release());
        setValueForExifKey(kGPSLatitudeRefKey, latRef.release());
        setValueForExifKey(kGPSLongitudeKey, lonVal.release());
        setValueForExifKey(kGPSLongitudeRefKey, lonRef.release());
    }
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
