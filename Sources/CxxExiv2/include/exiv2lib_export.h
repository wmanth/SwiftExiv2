/*
  =============================================================================
  MIT License

  Copyright (c) 2024 Wolfram Manthey

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.
  =============================================================================
 */

#ifndef EXIV2API_H
#define EXIV2API_H

#ifdef exiv2lib_STATIC
#  define EXIV2API
#  define EXIV2LIB_NO_EXPORT
#else
#  ifndef EXIV2API
#    ifdef exiv2lib_EXPORTS
        /* We are building this library */
#      define EXIV2API __attribute__((visibility("default")))
#    else
        /* We are using this library */
#      define EXIV2API __attribute__((visibility("default")))
#    endif
#  endif

#  ifndef EXIV2LIB_NO_EXPORT
#    define EXIV2LIB_NO_EXPORT __attribute__((visibility("hidden")))
#  endif
#endif

#ifndef EXIV2LIB_DEPRECATED
#  define EXIV2LIB_DEPRECATED __attribute__ ((__deprecated__))
#endif

#ifndef EXIV2LIB_DEPRECATED_EXPORT
#  define EXIV2LIB_DEPRECATED_EXPORT EXIV2API EXIV2LIB_DEPRECATED
#endif

#ifndef EXIV2LIB_DEPRECATED_NO_EXPORT
#  define EXIV2LIB_DEPRECATED_NO_EXPORT EXIV2LIB_NO_EXPORT EXIV2LIB_DEPRECATED
#endif

#if 0 /* DEFINE_NO_DEPRECATED */
#  ifndef EXIV2LIB_NO_DEPRECATED
#    define EXIV2LIB_NO_DEPRECATED
#  endif
#endif

#endif /* EXIV2API_H */
