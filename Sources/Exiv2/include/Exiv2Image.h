#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Exiv2Image : NSObject

- (instancetype)initWithURL:(NSURL*)url;

- (void)readMetadata;
- (void)writeMetadata;

@property (nullable) NSDateComponents* dateTimeModified;
@property (nullable) NSDateComponents* dateTimeOriginal;
@property (nullable) NSDateComponents* dateTimeDigitized;

@property (nullable) NSNumber* latitude;
@property (nullable) NSNumber* longitude;
@property (nullable) NSNumber* altitude;

@end

NS_ASSUME_NONNULL_END
