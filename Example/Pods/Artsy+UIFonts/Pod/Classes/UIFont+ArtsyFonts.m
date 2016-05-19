//
//  UIFont+ArtsyFonts.m
//  Artsy
//
//  Created by Orta Therox on 11/11/2011.
//  Copyright (c) 2011 Artsy. All rights reserved.
//

#import "UIFont+ArtsyFonts.h"
#import <CoreText/CoreText.h>

// Based on https://github.com/CocoaPods-Fonts/OpenSans/blob/874e65bc21abe54284e195484d2259b2fe858680/UIFont%2BOpenSans.m

@interface ARFontLoader: NSObject

+ (void)loadFontWithFileName:(NSString *)fontFileName extension:(NSString *)extension;

@end

@implementation ARFontLoader

+ (void)loadFontWithFileName:(NSString *)fontFileName extension:(NSString *)extension {
    NSBundle *bundle = [NSBundle bundleForClass:self];
    NSURL *fontURL = [bundle URLForResource:fontFileName withExtension:extension];
    NSData *fontData = [NSData dataWithContentsOfURL:fontURL];

    CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)fontData);
    CGFontRef font = CGFontCreateWithDataProvider(provider);

    if (font) {
        CFErrorRef errorRef = NULL;
        if (CTFontManagerRegisterGraphicsFont(font, &errorRef) == NO) {
            NSError *error = (__bridge NSError *)errorRef;
            if (error.code == kCTFontManagerErrorAlreadyRegistered) {
                // nop - the font must have been registered by someone else already. 
            } else {
                @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:error.localizedDescription userInfo:@{ NSUnderlyingErrorKey: error }];
            }
        }

        CFRelease(font);
    }

    CFRelease(provider);
}

@end

@implementation UIFont (ArtsyFonts)


+ (instancetype)ar_LoadAndReturnFont:(NSString *)fontName extension:(NSString *)extension size:(CGFloat)fontSize onceToken:(dispatch_once_t *)onceToken {
    // Overload to default to fontName for fontFileName
    return [self ar_LoadAndReturnFont:fontName extension:extension size:fontSize onceToken:onceToken fontFileName:fontName];
}

+ (instancetype)ar_LoadAndReturnFont:(NSString *)fontName extension:(NSString *)extension size:(CGFloat)fontSize onceToken:(dispatch_once_t *)onceToken fontFileName:(NSString *)fontFileName {

    dispatch_once(onceToken, ^{
        [ARFontLoader loadFontWithFileName:fontFileName extension:extension];
    });

    return [self fontWithName:fontName size:fontSize];
}

+ (UIFont *)serifBoldItalicFontWithSize:(CGFloat)size
{
    static dispatch_once_t onceToken;
    return [self ar_LoadAndReturnFont:@"AGaramondPro-BoldItalic" extension:@"otf" size:size onceToken:&onceToken];
}

+ (UIFont *)serifBoldFontWithSize:(CGFloat)size
{
    static dispatch_once_t onceToken;
    return [self ar_LoadAndReturnFont:@"AGaramondPro-Bold" extension:@"otf" size:size onceToken:&onceToken];
}

+ (UIFont *)serifSemiBoldFontWithSize:(CGFloat)size
{
    static dispatch_once_t onceToken;
    return [self ar_LoadAndReturnFont:@"AGaramondPro-Semibold" extension:@"otf" size:size onceToken:&onceToken];
}

+ (UIFont *)serifFontWithSize:(CGFloat)size
{
    static dispatch_once_t onceToken;
    return [self ar_LoadAndReturnFont:@"AGaramondPro-Regular" extension:@"otf" size:size onceToken:&onceToken];
}

+ (UIFont *)serifItalicFontWithSize:(CGFloat)size
{
    static dispatch_once_t onceToken;
    return [self ar_LoadAndReturnFont:@"AGaramondPro-Italic" extension:@"otf" size:size onceToken:&onceToken];
}

+ (UIFont *)sansSerifFontWithSize:(CGFloat)size
{
    static dispatch_once_t onceToken;
    return [self ar_LoadAndReturnFont:@"AvantGardeGothicITCW01Dm" extension:@"ttf" size:size onceToken:&onceToken fontFileName:@"ITCAvantGardeDemi_Track03"];
}

+ (UIFont *)smallCapsSerifFontWithSize:(CGFloat)size
{
    // Force font to be loaded into CoreText system first.
    __unused UIFont *font = [self serifFontWithSize:size];

    NSArray *fontFeatureSettings = @[ @{ UIFontFeatureTypeIdentifierKey: @(38),
                                         UIFontFeatureSelectorIdentifierKey : @(1) } ];

    NSDictionary *fontAttributes = @{ UIFontDescriptorFeatureSettingsAttribute: fontFeatureSettings,
                                      UIFontDescriptorNameAttribute: @"AGaramondPro-Regular",
                                      UIFontDescriptorSizeAttribute: @(size)};

    UIFontDescriptor *fontDescriptor = [[UIFontDescriptor alloc] initWithFontAttributes: fontAttributes];
    return [UIFont fontWithDescriptor:fontDescriptor size:size];
}

@end
