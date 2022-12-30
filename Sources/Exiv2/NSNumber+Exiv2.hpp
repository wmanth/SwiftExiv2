#import <Foundation/Foundation.h>

#include "exiv2/exiv2.hpp"

NS_ASSUME_NONNULL_BEGIN

@interface NSNumber (Exiv2)

+ (nullable NSNumber *)fromURational:(Exiv2::URationalValue *)value negative:(BOOL)negative;
+ (nullable NSNumber *)fromDMS:(Exiv2::URationalValue *)value negative:(BOOL)negative;

- (Exiv2::URationalValue)toURationalWithDenominator:(int)denominator;
- (Exiv2::URationalValue)toDMS;

@end

NS_ASSUME_NONNULL_END
