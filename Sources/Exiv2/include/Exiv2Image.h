#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Exiv2Image : NSObject

- (instancetype)initWithURL:(NSURL*)url;

- (void)readMetadata;
- (void)writeMetadata;

- (nullable NSDateComponents *)getDateTimeModified;
- (nullable NSDateComponents *)getDateTimeOriginal;
- (nullable NSDateComponents *)getDateTimeDigitized;
- (void)setDateTimeModified:(NSDateComponents *)dateTime;
- (void)setDateTimeOriginal:(NSDateComponents *)dateTime;
- (void)setDateTimeDigitized:(NSDateComponents *)dateTime;

- (nullable NSNumber *)getLatitude;
- (void)setLatitude:(NSNumber *)latitude;

- (nullable NSNumber *)getLongitude;
- (void)setLongitude:(NSNumber *)longitude;

- (nullable NSNumber *)getAltitude;
- (void)setAltitude:(NSNumber *)altitude;

@property (readonly) NSURL* url;

@end

NS_ASSUME_NONNULL_END
