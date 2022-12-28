#import "Exiv2Image.hpp"

const char* const kGPSLatitude      = "Exif.GPSInfo.GPSLatitude";
const char* const kGPSLatitudeRef   = "Exif.GPSInfo.GPSLatitudeRef";
const char* const kGPSLongitude     = "Exif.GPSInfo.GPSLongitude";
const char* const kGPSLongitudeRef  = "Exif.GPSInfo.GPSLongitudeRef";

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

- (nullable NSNumber *)dmsToDouble:(Exiv2::URationalValue *)rValue negative:(BOOL)negative {
    if (rValue == NULL || rValue->count() != 3) { return NULL; }

    Exiv2::Rational rDeg = rValue->toRational(0);
    Exiv2::Rational rMin = rValue->toRational(1);
    Exiv2::Rational rSec = rValue->toRational(2);

    double deg = (double)rDeg.first/rDeg.second;
    double min = (double)rMin.first/rMin.second;
    double sec = (double)rSec.first/rSec.second;

    int sign = negative ? -1 : 1;
    return [NSNumber numberWithDouble:sign * ((sec/60 + min)/60 + deg)];
}

- (Exiv2::URationalValue)doubleToDms:(double)value {
    int deg = (int)value;
        value -= deg;
        value *= 60;
    int min = (int)value;
        value -= min;
        value *= 60;
    int sec = (int)(value * 1000);

    Exiv2::URationalValue rv;
    rv.value_.push_back(std::make_pair(deg, 1));
    rv.value_.push_back(std::make_pair(min, 1));
    rv.value_.push_back(std::make_pair(sec, 1000));

    return rv;
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

- (Exiv2::URationalValue*)rationalValueForExifKey:(const char *)keyName {
    Exiv2::Value::AutoPtr value = [self valueForExifKey:keyName];
    return dynamic_cast<Exiv2::URationalValue*>(value.release());
}

- (NSNumber *)getLatitude {
    Exiv2::AsciiValue* latRef = [self asciiValueForExifKey:kGPSLatitudeRef];
    Exiv2::URationalValue* latVal = [self rationalValueForExifKey:kGPSLatitude];
    return (latRef && latVal) ?
        [self dmsToDouble:latVal negative:(latRef->toString() == "S")] : NULL;
}

- (NSNumber *)getLongitude {
    Exiv2::AsciiValue* lonRef = [self asciiValueForExifKey:kGPSLongitudeRef];
    Exiv2::URationalValue* lonVal = [self rationalValueForExifKey:kGPSLongitude];
    return (lonRef && lonVal) ?
        [self dmsToDouble:lonVal negative:lonRef->toString() == "W"] : NULL;
}

- (void)setLatitude:(NSNumber *)latitude {
    Exiv2::ExifData& exifData = _image_ptr->exifData();
    exifData[kGPSLatitude] = [self doubleToDms:abs(latitude.doubleValue)];
    exifData[kGPSLatitudeRef] = latitude.doubleValue > 0 ? "N" : "S";
}

- (void)setLongitude:(NSNumber *)longitude {
    Exiv2::ExifData& exifData = _image_ptr->exifData();
    exifData[kGPSLongitude] = [self doubleToDms:abs(longitude.doubleValue)];
    exifData[kGPSLongitudeRef] = longitude.doubleValue > 0 ? "E" : "W";
}

@end
