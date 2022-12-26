#import "Exiv2Image.h"

#include "exiv2/exiv2.hpp"

@interface Exiv2Image ()

@property Exiv2::Image::AutoPtr image_ptr;

@end

@implementation Exiv2Image

- (instancetype)initWithImage:(Exiv2::Image::AutoPtr)image {
    self.image_ptr = image;
}

+ (Exiv2Image*)imageFromBuffer:(const char*)data size:(long)size {
    Exiv2::Image::AutoPtr image = Exiv2::ImageFactory::open(data, size);
    return [[Exiv2Image alloc] initWithImage:image];
}

@end
