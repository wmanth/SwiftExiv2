#import <Foundation/Foundation.h>

#import "exiv2/exiv2.hpp"

NS_ASSUME_NONNULL_BEGIN

@interface NSNumber (Exiv2)

+ (nullable NSNumber *)fromURational:(const Exiv2::Value &)value negative:(BOOL)negative;
+ (nullable NSNumber *)fromDegMinSec:(const Exiv2::Value &)value negative:(BOOL)negative;

- (Exiv2::Value::AutoPtr)toURationalWithDenominator:(int)denominator;
- (Exiv2::Value::AutoPtr)toDegMinSec;

@end

#pragma mark -

@interface NSDate (Exiv2)

+ (nullable NSDate *)fromDateValue:(nullable const Exiv2::Value *)dateTimeValue
                     timeZoneValue:(nullable const Exiv2::Value *)timeZoneValue;

@end

#pragma mark -

@interface NSDateComponents (Exiv2)

+ (nullable NSDateComponents *)fromDateValue:(nullable const Exiv2::Value *)dateTimeValue
                               timeZoneValue:(nullable const Exiv2::Value *)timeZoneValue;
- (Exiv2::Value::AutoPtr)toValue;

@end

#pragma mark -

@interface NSTimeZone (Exiv2)

+ (nullable NSTimeZone *)fromValue:(const Exiv2::Value *)value;

- (Exiv2::Value::AutoPtr)toValue;

@end

NS_ASSUME_NONNULL_END
