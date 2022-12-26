#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Exiv2Image : NSObject

+ (Exiv2Image*)imageFromBuffer:(const char*)data size:(long)size;

@end

NS_ASSUME_NONNULL_END
