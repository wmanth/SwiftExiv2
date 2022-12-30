#import "Exiv2Image.hpp"

#import "NSNumber+Exiv2.hpp"

const char* const kGPSLatitude      = "Exif.GPSInfo.GPSLatitude";
const char* const kGPSLatitudeRef   = "Exif.GPSInfo.GPSLatitudeRef";
const char* const kGPSLongitude     = "Exif.GPSInfo.GPSLongitude";
const char* const kGPSLongitudeRef  = "Exif.GPSInfo.GPSLongitudeRef";
const char* const kGPSAltitude      = "Exif.GPSInfo.GPSAltitude";
const char* const kGPSAltitudeRef   = "Exif.GPSInfo.GPSAltitudeRef";

@implementation Exiv2Image

- (instancetype)initWithPath:(NSString*)path {
    if (self = [super init]) {
        const char* imagePath = [path cStringUsingEncoding:NSUTF8StringEncoding];
        Exiv2::Image::AutoPtr image = Exiv2::ImageFactory::open(imagePath);
        _image_ptr = image;
    }
    return self;
}

- (void)readMetadata {
    _image_ptr->readMetadata();
}

- (void)writeMetadata {
    _image_ptr->writeMetadata();
}

- (Exiv2::Value::AutoPtr)valueForExifKey:(const char *)keyName {
    Exiv2::ExifData& exifData = _image_ptr->exifData();
    Exiv2::ExifKey key(keyName);
    Exiv2::ExifData::iterator pos = exifData.findKey(key);
    if (pos == exifData.end()) { return Exiv2::Value::AutoPtr(NULL); }
    return pos->getValue();
}

- (Exiv2::AsciiValue*)asciiValueForExifKey:(const char *)keyName {
    Exiv2::Value::AutoPtr value = [self valueForExifKey:keyName];
    return dynamic_cast<Exiv2::AsciiValue*>(value.release());
}

- (Exiv2::DataValue*)dataValueForExifKey:(const char *)keyName {
    Exiv2::Value::AutoPtr value = [self valueForExifKey:keyName];
    return dynamic_cast<Exiv2::DataValue*>(value.release());
}

- (Exiv2::URationalValue*)rationalValueForExifKey:(const char *)keyName {
    Exiv2::Value::AutoPtr value = [self valueForExifKey:keyName];
    return dynamic_cast<Exiv2::URationalValue*>(value.release());
}

- (NSNumber *)getLatitude {
    Exiv2::AsciiValue* latRef = [self asciiValueForExifKey:kGPSLatitudeRef];
    Exiv2::URationalValue* latVal = [self rationalValueForExifKey:kGPSLatitude];
    return (latRef && latVal) ?
        [NSNumber fromDMS:latVal negative:(latRef->toString() == "S")] : NULL;
}

- (NSNumber *)getLongitude {
    Exiv2::AsciiValue* lonRef = [self asciiValueForExifKey:kGPSLongitudeRef];
    Exiv2::URationalValue* lonVal = [self rationalValueForExifKey:kGPSLongitude];
    return (lonRef && lonVal) ?
        [NSNumber fromDMS:lonVal negative:lonRef->toString() == "W"] : NULL;
}

- (void)setLatitude:(NSNumber *)latitude {
    Exiv2::ExifData& exifData = _image_ptr->exifData();
    exifData[kGPSLatitude] = latitude.toDMS;
    exifData[kGPSLatitudeRef] = latitude.doubleValue > 0 ? "N" : "S";
}

- (void)setLongitude:(NSNumber *)longitude {
    Exiv2::ExifData& exifData = _image_ptr->exifData();
    exifData[kGPSLongitude] = longitude.toDMS;
    exifData[kGPSLongitudeRef] = longitude.doubleValue > 0 ? "E" : "W";
}

- (nullable NSNumber *)getAltitude {
    Exiv2::DataValue* altRef = [self dataValueForExifKey:kGPSAltitudeRef];
    Exiv2::URationalValue* altVal = [self rationalValueForExifKey:kGPSAltitude];
    return (altRef && altVal) ?
        [NSNumber fromURational:altVal negative:(altRef->toLong() == 1)] : NULL;
}

- (void)setAltitude:(NSNumber *)altitude {
    Exiv2::ExifData& exifData = _image_ptr->exifData();
    exifData[kGPSAltitude] = [altitude toURationalWithDenominator:100];
    exifData[kGPSAltitudeRef] = altitude.intValue > 0 ? "0" : "1";
}

@end
