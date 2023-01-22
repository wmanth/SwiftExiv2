#import "Exiv2Image.hpp"

#import "Categories.hpp"

using namespace Exiv2;

const ExifKey kImageDateTimeKey    = ExifKey("Exif.Image.DateTime");

const ExifKey kPhotoOffsetTimeKey           = ExifKey("Exif.Photo.OffsetTime");
const ExifKey kPhotoDateTimeOriginalKey     = ExifKey("Exif.Photo.DateTimeOriginal");
const ExifKey kPhotoDateTimeDigitizedKey    = ExifKey("Exif.Photo.DateTimeDigitized");
const ExifKey kPhotoOffsetTimeOriginalKey   = ExifKey("Exif.Photo.OffsetTimeOriginal");
const ExifKey kPhotoOffsetTimeDigitizedKey  = ExifKey("Exif.Photo.OffsetTimeDigitized");

const ExifKey kGPSLatitudeKey      = ExifKey("Exif.GPSInfo.GPSLatitude");
const ExifKey kGPSLatitudeRefKey   = ExifKey("Exif.GPSInfo.GPSLatitudeRef");
const ExifKey kGPSLongitudeKey     = ExifKey("Exif.GPSInfo.GPSLongitude");
const ExifKey kGPSLongitudeRefKey  = ExifKey("Exif.GPSInfo.GPSLongitudeRef");
const ExifKey kGPSAltitudeKey      = ExifKey("Exif.GPSInfo.GPSAltitude");
const ExifKey kGPSAltitudeRefKey   = ExifKey("Exif.GPSInfo.GPSAltitudeRef");

@implementation Exiv2Image

- (instancetype)initWithPath:(NSString*)path {
    if (self = [super init]) {
        _image_ptr = ImageFactory::open(path.UTF8String);
    }
    return self;
}

- (void)readMetadata {
    _image_ptr->readMetadata();
}

- (void)writeMetadata {
    _image_ptr->writeMetadata();
}

- (Value::AutoPtr)valueForExifKey:(const ExifKey &)key {
    auto exifData = _image_ptr->exifData();
    auto pos = exifData.findKey(key);
    if (pos == exifData.end()) return Value::AutoPtr();
    return pos->getValue();
}

- (void)setValue:(const Value *)pValue forExifKey:(const ExifKey &)key {
    auto& exifData = _image_ptr->exifData();
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

- (NSString *)description {
    auto begin = _image_ptr->exifData().begin();
    auto end = _image_ptr->exifData().end();

    NSMutableString *result = [NSMutableString new];
    for (auto it = begin; it != end; ++it) {
        [result appendFormat:@"\n%s (%s) -> %s", it->key().c_str(), it->typeName(), it->value().toString().c_str()];
    }
    return result;
}

- (nullable NSDateComponents *)getDateTimeModified {
    auto dateTimeValue = [self valueForExifKey:kImageDateTimeKey];
    auto timeZoneValue = [self valueForExifKey:kPhotoOffsetTimeKey];

    return [NSDateComponents fromDateValue:dateTimeValue.get()
                             timeZoneValue:timeZoneValue.get()];
}

- (nullable NSDateComponents *)getDateTimeOriginal {
    auto dateTimeValue = [self valueForExifKey:kPhotoDateTimeOriginalKey];
    auto timeZoneValue = [self valueForExifKey:kPhotoOffsetTimeOriginalKey];

    return [NSDateComponents fromDateValue:dateTimeValue.get()
                             timeZoneValue:timeZoneValue.get()];
}

- (nullable NSDateComponents *)getDateTimeDigitized {
    auto dateTimeValue = [self valueForExifKey:kPhotoDateTimeDigitizedKey];
    auto timeZoneValue = [self valueForExifKey:kPhotoOffsetTimeDigitizedKey];

    return [NSDateComponents fromDateValue:dateTimeValue.get()
                             timeZoneValue:timeZoneValue.get()];

}

- (void)setDateTimeModified:(NSDateComponents *)dateTimeComponents {
    [self setValue:dateTimeComponents.toValue.get() forExifKey:kImageDateTimeKey];
    [self setValue:dateTimeComponents.timeZone.toValue.get() forExifKey:kPhotoOffsetTimeKey];
}

- (void)setDateTimeOriginal:(NSDateComponents *)dateTimeComponents {
    [self setValue:dateTimeComponents.toValue.get() forExifKey:kPhotoDateTimeOriginalKey];
    [self setValue:dateTimeComponents.timeZone.toValue.get() forExifKey:kPhotoOffsetTimeOriginalKey];
}

- (void)setDateTimeDigitized:(NSDateComponents *)dateTimeComponents {
    [self setValue:dateTimeComponents.toValue.get() forExifKey:kPhotoDateTimeDigitizedKey];
    [self setValue:dateTimeComponents.timeZone.toValue.get() forExifKey:kPhotoOffsetTimeDigitizedKey];
}

- (nullable NSNumber *)getLatitude {
    auto latRef = [self valueForExifKey:kGPSLatitudeRefKey];
    auto latVal = [self valueForExifKey:kGPSLatitudeKey];

    return (latRef.get() && latVal.get()) ?
        [NSNumber fromDegMinSec:latVal.get() negative:(latRef->toString() == "S")] : nil;
}

- (nullable NSNumber *)getLongitude {
    auto lonRef = [self valueForExifKey:kGPSLongitudeRefKey];
    auto lonVal = [self valueForExifKey:kGPSLongitudeKey];
    return (lonRef.get() && lonVal.get()) ?
        [NSNumber fromDegMinSec:lonVal.get() negative:lonRef->toString() == "W"] : nil;
}

- (void)setLatitude:(NSNumber *)latitude {
    auto latitudeVal = latitude.toDegMinSec;
    auto latitudeRef = AsciiValue(latitude.doubleValue > 0 ? "N" : "S");

    [self setValue:latitudeVal.get() forExifKey:kGPSLatitudeKey];
    [self setValue:latitudeVal.get() ? &latitudeRef : NULL forExifKey:kGPSLatitudeRefKey];
}

- (void)setLongitude:(NSNumber *)longitude {
    auto longitudeVal = longitude.toDegMinSec;
    auto longitudeRef = AsciiValue(longitude.doubleValue > 0 ? "E" : "W");

    [self setValue:longitudeVal.get() forExifKey:kGPSLongitudeKey];
    [self setValue:longitudeVal.get() ? &longitudeRef : NULL forExifKey:kGPSLongitudeRefKey];
}

- (nullable NSNumber *)getAltitude {
    auto altitudeRef = [self valueForExifKey:kGPSAltitudeRefKey];
    auto altitudeVal = [self valueForExifKey:kGPSAltitudeKey];
    return (altitudeRef.get() && altitudeVal.get()) ?
        [NSNumber fromURational:altitudeVal.get() negative:(altitudeRef->toLong() == 1)] : nil;
}

- (void)setAltitude:(NSNumber *)altitude {
    auto altitudeVal = [altitude toURationalWithDenominator:100];
    auto altitudeRef = AsciiValue(altitude.intValue > 0 ? "0" : "1");
    [self setValue:altitudeVal.get() forExifKey:kGPSAltitudeKey];
    [self setValue:altitudeVal.get() ? &altitudeRef : NULL forExifKey:kGPSAltitudeRefKey];
}

@end
