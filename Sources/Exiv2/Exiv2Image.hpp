#import "Exiv2Image.h"

#include "exiv2/exiv2.hpp"

@interface Exiv2Image () {
    Exiv2::Image::AutoPtr _image_ptr;
}

@end
