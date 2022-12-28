#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Exiv2Image : NSObject

- (instancetype)initWithPath:(NSString*)path;

- (void)readMetadata;
- (void)writeMetadata;

- (nullable NSNumber *)getLatitude;
- (void)setLatitude:(NSNumber *)latitude;

- (nullable NSNumber *)getLongitude;
- (void)setLongitude:(NSNumber *)longitude;

@end

NS_ASSUME_NONNULL_END
