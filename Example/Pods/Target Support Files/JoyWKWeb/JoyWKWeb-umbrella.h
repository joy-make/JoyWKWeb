#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "ResourcePackageManager.h"
#import "TabBarVC.h"
#import "UrlRedirectionProtocol.h"
#import "WebVC+JSNative.h"
#import "WebVC.h"

FOUNDATION_EXPORT double JoyWKWebVersionNumber;
FOUNDATION_EXPORT const unsigned char JoyWKWebVersionString[];

