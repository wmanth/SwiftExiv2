#import "Exiv2Image.hpp"

#import "Categories.hpp"

const std::string kImageDateTimeKey    = "Exif.Image.DateTime";
const std::string kPhotoOffsetTimeKey  = "Exif.Photo.OffsetTime";

const std::string kPhotoDateTimeOriginalKey     = "Exif.Photo.DateTimeOriginal";
const std::string kPhotoDateTimeDigitizedKey    = "Exif.Photo.DateTimeDigitized";
const std::string kPhotoOffsetTimeOriginalKey   = "Exif.Photo.OffsetTimeOriginal";
const std::string kPhotoOffsetTimeDigitizedKey  = "Exif.Photo.OffsetTimeDigitized";

const std::string kGPSLatitudeKey      = "Exif.GPSInfo.GPSLatitude";
const std::string kGPSLatitudeRefKey   = "Exif.GPSInfo.GPSLatitudeRef";
const std::string kGPSLongitudeKey     = "Exif.GPSInfo.GPSLongitude";
const std::string kGPSLongitudeRefKey  = "Exif.GPSInfo.GPSLongitudeRef";
const std::string kGPSAltitudeKey      = "Exif.GPSInfo.GPSAltitude";
const std::string kGPSAltitudeRefKey   = "Exif.GPSInfo.GPSAltitudeRef";

@implementation Exiv2Image

- (instancetype)initWithPath:(NSString*)path {
    if (self = [super init]) {
        _image_ptr = Exiv2::ImageFactory::open(path.UTF8String);
    }
    return self;
}

- (void)readMetadata {
    _image_ptr->readMetadata();
}

- (void)writeMetadata {
    _image_ptr->writeMetadata();
}

- (Exiv2::Value::AutoPtr)valueForExifKey:(const std::string &)keyName {
    Exiv2::ExifData& exifData = _image_ptr->exifData();
    Exiv2::ExifKey key(keyName);
    Exiv2::ExifData::iterator pos = exifData.findKey(key);
    if (pos == exifData.end()) { return Exiv2::Value::AutoPtr(); }
    return pos->getValue();
}

- (NSString *)description {
    Exiv2::ExifData::const_iterator begin = _image_ptr->exifData().begin();
    Exiv2::ExifData::const_iterator end = _image_ptr->exifData().end();

    NSMutableString *result = [NSMutableString new];
    for (Exiv2::ExifData::const_iterator it = begin; it != end; ++it) {
        [result appendFormat:@"\n%s (%s) -> %s", it->key().c_str(), it->typeName(), it->value().toString().c_str()];
    }
    return result;
}

- (nullable NSDateComponents *)getDateTimeModified {
    Exiv2::Value::AutoPtr dateTimeValue = [self valueForExifKey:kImageDateTimeKey];
    Exiv2::Value::AutoPtr timeZoneValue = [self valueForExifKey:kPhotoOffsetTimeKey];

    return [NSDateComponents fromDateValue:dateTimeValue.get()
                             timeZoneValue:timeZoneValue.get()];
}

- (nullable NSDateComponents *)getDateTimeOriginal {
    Exiv2::Value::AutoPtr dateTimeValue = [self valueForExifKey:kPhotoDateTimeOriginalKey];
    Exiv2::Value::AutoPtr timeZoneValue = [self valueForExifKey:kPhotoOffsetTimeOriginalKey];

    return [NSDateComponents fromDateValue:dateTimeValue.get()
                             timeZoneValue:timeZoneValue.get()];
}

- (nullable NSDateComponents *)getDateTimeDigitized {
    Exiv2::Value::AutoPtr dateTimeValue = [self valueForExifKey:kPhotoDateTimeDigitizedKey];
    Exiv2::Value::AutoPtr timeZoneValue = [self valueForExifKey:kPhotoOffsetTimeDigitizedKey];

    return [NSDateComponents fromDateValue:dateTimeValue.get()
                             timeZoneValue:timeZoneValue.get()];

}

- (void)setDateTimeModified:(NSDateComponents *)dateTimeComponents {
    Exiv2::ExifData& exifData = _image_ptr->exifData();
    exifData[kImageDateTimeKey] = *dateTimeComponents.toValue;
    exifData[kPhotoOffsetTimeKey] = *dateTimeComponents.timeZone.toValue;
}

- (void)setDateTimeOriginal:(NSDateComponents *)dateTimeComponents {
    Exiv2::ExifData& exifData = _image_ptr->exifData();
    exifData[kPhotoDateTimeOriginalKey] = *dateTimeComponents.toValue;
    exifData[kPhotoOffsetTimeOriginalKey] = *dateTimeComponents.timeZone.toValue;
}

- (void)setDateTimeDigitized:(NSDateComponents *)dateTimeComponents {
    Exiv2::ExifData& exifData = _image_ptr->exifData();
    exifData[kPhotoDateTimeDigitizedKey] = *dateTimeComponents.toValue;
    exifData[kPhotoOffsetTimeDigitizedKey] = *dateTimeComponents.timeZone.toValue;
}

- (nullable NSNumber *)getLatitude {
    Exiv2::Value::AutoPtr latRef = [self valueForExifKey:kGPSLatitudeRefKey];
    Exiv2::Value::AutoPtr latVal = [self valueForExifKey:kGPSLatitudeKey];
    return (latRef.get() && latVal.get()) ?
        [NSNumber fromDegMinSec:*latVal negative:(latRef->toString() == "S")] : nil;
}

- (nullable NSNumber *)getLongitude {
    Exiv2::Value::AutoPtr lonRef = [self valueForExifKey:kGPSLongitudeRefKey];
    Exiv2::Value::AutoPtr lonVal = [self valueForExifKey:kGPSLongitudeKey];
    return (lonRef.get() && lonVal.get()) ?
        [NSNumber fromDegMinSec:*lonVal negative:lonRef->toString() == "W"] : nil;
}

- (void)setLatitude:(NSNumber *)latitude {
    Exiv2::ExifData& exifData = _image_ptr->exifData();
    exifData[kGPSLatitudeKey] = *latitude.toDegMinSec;
    exifData[kGPSLatitudeRefKey] = latitude.doubleValue > 0 ? "N" : "S";
}

- (void)setLongitude:(NSNumber *)longitude {
    Exiv2::ExifData& exifData = _image_ptr->exifData();
    exifData[kGPSLongitudeKey] = *longitude.toDegMinSec;
    exifData[kGPSLongitudeRefKey] = Exiv2::AsciiValue(longitude.doubleValue > 0 ? "E" : "W");
}

- (nullable NSNumber *)getAltitude {
    Exiv2::Value::AutoPtr altRef = [self valueForExifKey:kGPSAltitudeRefKey];
    Exiv2::Value::AutoPtr altVal = [self valueForExifKey:kGPSAltitudeKey];
    return (altRef.get() && altVal.get()) ?
        [NSNumber fromURational:*altVal negative:(altRef->toLong() == 1)] : nil;
}

- (void)setAltitude:(NSNumber *)altitude {
    Exiv2::ExifData& exifData = _image_ptr->exifData();
    exifData[kGPSAltitudeKey] = *[altitude toURationalWithDenominator:100];
    exifData[kGPSAltitudeRefKey] = altitude.intValue > 0 ? "0" : "1";
}

@end
