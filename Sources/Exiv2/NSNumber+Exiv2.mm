#import "NSNumber+Exiv2.hpp"

@implementation NSNumber (Exiv2)

+ (nullable NSNumber *)fromURational:(Exiv2::URationalValue *)value negative:(BOOL)negative {
    int sign = negative ? -1 : 1;
    return [NSNumber numberWithFloat:value->toFloat() * sign];
}

+ (nullable NSNumber *)fromDMS:(Exiv2::URationalValue *)value negative:(BOOL)negative {
    if (value == NULL || value->count() != 3) { return NULL; }

    float deg = value->toFloat(0);
    float min = value->toFloat(1);
    float sec = value->toFloat(2);

    int sign = negative ? -1 : 1;
    return [NSNumber numberWithFloat:sign * ((sec/60 + min)/60 + deg)];
}

- (Exiv2::URationalValue)toURationalWithDenominator:(int)denominator {
    Exiv2::URationalValue result;
    result.value_.push_back(std::make_pair((int)(abs(self.floatValue) * denominator), denominator));
    return result;
}

- (Exiv2::URationalValue)toDMS {
    double value = abs(self.doubleValue);
    int deg = (int)value;
        value -= deg;
        value *= 60;
    int min = (int)value;
        value -= min;
        value *= 60;
    int sec = (int)(value * 1000);

    Exiv2::URationalValue result;
    result.value_.push_back(std::make_pair(deg, 1));
    result.value_.push_back(std::make_pair(min, 1));
    result.value_.push_back(std::make_pair(sec, 1000));

    return result;
}

@end
