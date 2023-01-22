#import "Categories.hpp"

using namespace Exiv2;

@implementation NSNumber (Exiv2)

+ (nullable NSNumber *)fromURational:(const Value *)pValue
                            negative:(BOOL)negative
{
    if (!pValue) return nil;

    int sign = negative ? -1 : 1;
    return [NSNumber numberWithFloat:pValue->toFloat() * sign];
}

+ (nullable NSNumber *)fromDegMinSec:(const Value *)pValue
                            negative:(BOOL)negative
{
    if (!pValue || pValue->count() != 3) return nil;

    float deg = pValue->toFloat(0);
    float min = pValue->toFloat(1);
    float sec = pValue->toFloat(2);

    int sign = negative ? -1 : 1;
    return [NSNumber numberWithFloat:sign * ((sec/60 + min)/60 + deg)];
}

- (Value::AutoPtr)toURationalWithDenominator:(int)denominator
{
    auto *pValue = new URationalValue();
    pValue->value_.push_back(URational(abs(self.floatValue * denominator), denominator));
    return Value::AutoPtr(pValue);
}

- (Value::AutoPtr)toDegMinSec
{
    float value = abs(self.floatValue);
    int deg = (int)value;
        value -= deg;
        value *= 60;
    int min = (int)value;
        value -= min;
        value *= 60;
    int sec = (int)(value * 1000);

    auto *pValue = new URationalValue();
    pValue->value_.push_back(URational(deg, 1));
    pValue->value_.push_back(URational(min, 1));
    pValue->value_.push_back(URational(sec, 1000));

    return Value::AutoPtr(pValue);
}

@end

#pragma mark -

@implementation NSDate (Exiv2)

+ (nullable NSDate *)fromDateValue:(const Value *)pDateTimeValue
                     timeZoneValue:(const Value *)pTimeZoneValue
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

+ (nullable NSDateComponents *)fromDateValue:(nullable const Value *)pDateTimeValue
                               timeZoneValue:(nullable const Value *)pTimeZoneValue;
{
    if (!pDateTimeValue) return nil;
    
    NSDate *date = [NSDate fromDateValue:pDateTimeValue
                           timeZoneValue:pTimeZoneValue];

    NSTimeZone *timeZone = [NSTimeZone fromValue:pTimeZoneValue];
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierISO8601];
    return [calendar componentsInTimeZone:timeZone fromDate:date];
}

- (Value::AutoPtr)toValue
{
    NSString *dateTimeString = [NSString stringWithFormat:@"%04d:%02d:%02d %02d:%02d:%02d",
                                (int)self.year, (int)self.month, (int)self.day,
                                (int)self.hour, (int)self.minute, (int)self.second];
    return Value::AutoPtr(new AsciiValue(dateTimeString.UTF8String));
}

@end

#pragma mark -

@implementation NSTimeZone (Exiv2)

+ (nullable NSTimeZone *)fromValue:(const Value *)pValue
{
    if (!pValue) return nil;

    NSString *timeZoneName = [NSString stringWithFormat:@"GMT%s", pValue ? pValue->toString().c_str() : "+00:00"];
    return [NSTimeZone timeZoneWithName:timeZoneName];
}

- (Value::AutoPtr)toValue {
    NSInteger sec = [self secondsFromGMT];
    BOOL isNegative = (sec < 0);
    if (isNegative) sec = -sec;
    NSInteger hour = sec / 60 / 60;
    sec -= hour * 60 * 60;
    NSInteger min = sec / 60;
    NSString *str = [NSString stringWithFormat:@"%s%02ld:%02ld", isNegative ? "-" : "+", hour, min];
    return Value::AutoPtr(new AsciiValue(str.UTF8String));
}

@end
