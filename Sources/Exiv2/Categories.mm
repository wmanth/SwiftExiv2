#import "Categories.hpp"

@implementation NSNumber (Exiv2)

+ (nullable NSNumber *)fromURational:(const Exiv2::Value &)value
                            negative:(BOOL)negative
{
    int sign = negative ? -1 : 1;
    return [NSNumber numberWithFloat:value.toFloat() * sign];
}

+ (nullable NSNumber *)fromDegMinSec:(const Exiv2::Value &)value
                            negative:(BOOL)negative
{
    if (value.count() != 3) return nil;

    float deg = value.toFloat(0);
    float min = value.toFloat(1);
    float sec = value.toFloat(2);

    int sign = negative ? -1 : 1;
    return [NSNumber numberWithFloat:sign * ((sec/60 + min)/60 + deg)];
}

- (Exiv2::Value::AutoPtr)toURationalWithDenominator:(int)denominator
{
    Exiv2::URationalValue *result = new Exiv2::URationalValue();
    result->value_.push_back(Exiv2::URational(abs(self.floatValue) * denominator, denominator));
    return Exiv2::Value::AutoPtr(result);
}

- (Exiv2::Value::AutoPtr)toDegMinSec
{
    double value = abs(self.doubleValue);
    int deg = (int)value;
        value -= deg;
        value *= 60;
    int min = (int)value;
        value -= min;
        value *= 60;
    int sec = (int)(value * 1000);

    Exiv2::URationalValue *result = new Exiv2::URationalValue();
    result->value_.push_back(Exiv2::URational(deg, 1));
    result->value_.push_back(Exiv2::URational(min, 1));
    result->value_.push_back(Exiv2::URational(sec, 1000));

    return Exiv2::Value::AutoPtr(result);
}

@end

#pragma mark -

@implementation NSDate (Exiv2)

+ (nullable NSDate *)fromDateValue:(const Exiv2::Value *)pDateTimeValue
                     timeZoneValue:(const Exiv2::Value *)pTimeZoneValue
{
    if (!pDateTimeValue) return nil;

    NSString *dateTimeString = [NSString stringWithFormat:@"%s%s",
                                     pDateTimeValue->toString().c_str(),
                                     pTimeZoneValue ? pTimeZoneValue->toString().c_str() : "+00:00"];

    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyy:MM:dd' 'HH:mm:ssZZZZZ";
    return [dateFormatter dateFromString:dateTimeString];
}

@end

#pragma mark -

@implementation NSDateComponents (Exiv2)

+ (nullable NSDateComponents *)fromDateValue:(nullable const Exiv2::Value *)pDateTimeValue
                               timeZoneValue:(nullable const Exiv2::Value *)pTimeZoneValue;
{
    if (!pDateTimeValue) return nil;
    
    NSDate *date = [NSDate fromDateValue:pDateTimeValue
                           timeZoneValue:pTimeZoneValue];

    NSTimeZone *timeZone = [NSTimeZone fromValue:pTimeZoneValue];
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierISO8601];
    return [calendar componentsInTimeZone:timeZone fromDate:date];
}

- (Exiv2::Value::AutoPtr)toValue
{
    NSString *dateTimeString = [NSString stringWithFormat:@"%04d:%02d:%02d %02d:%02d:%02d",
                                (int)self.year, (int)self.month, (int)self.day,
                                (int)self.hour, (int)self.minute, (int)self.second];
    Exiv2::Value::AutoPtr value(new Exiv2::AsciiValue(dateTimeString.UTF8String));
    return value;
}

@end

#pragma mark -

@implementation NSTimeZone (Exiv2)

+ (nullable NSTimeZone *)fromValue:(const Exiv2::Value *)pValue
{
    if (!pValue) return nil;

    NSString *timeZoneName = [NSString stringWithFormat:@"GMT%s", pValue ? pValue->toString().c_str() : "+00:00"];
    return [NSTimeZone timeZoneWithName:timeZoneName];
}

- (Exiv2::Value::AutoPtr)toValue {
    NSInteger sec = [self secondsFromGMT];
    BOOL isNegative = (sec < 0);
    if (isNegative) sec = -sec;
    NSInteger hour = sec / 60 / 60;
    sec -= hour * 60 * 60;
    NSInteger min = sec / 60;
    NSString *str = [NSString stringWithFormat:@"%s%02ld:%02ld", isNegative ? "-" : "+", hour, min];
    return Exiv2::Value::AutoPtr(new Exiv2::AsciiValue(str.UTF8String));
}

@end
