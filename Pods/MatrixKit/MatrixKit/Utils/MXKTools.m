/*
 Copyright 2015 OpenMarket Ltd
 Copyright 2017 Vector Creations Ltd
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "MXKTools.h"

#import <AddressBook/AddressBook.h>

#import "NSBundle+MatrixKit.h"

#import "NBPhoneNumberUtil.h"

#import "MXCall.h"

@implementation MXKTools

#pragma mark - Strings

+ (BOOL)isSingleEmojiString:(NSString *)string
{
    return [MXKTools isEmojiString:string singleEmoji:YES];
}

+ (BOOL)isEmojiOnlyString:(NSString *)string
{
    return [MXKTools isEmojiString:string singleEmoji:NO];
}

// Highly inspired from https://stackoverflow.com/a/34659249
+ (BOOL)isEmojiString:(NSString*)string singleEmoji:(BOOL)singleEmoji
{
    if (string.length == 0)
    {
        return NO;
    }

    __block BOOL result = YES;

    NSRange stringRange = NSMakeRange(0, [string length]);

    [string enumerateSubstringsInRange:stringRange
                               options:NSStringEnumerationByComposedCharacterSequences
                            usingBlock:^(NSString *substring,
                                         NSRange substringRange,
                                         NSRange enclosingRange,
                                         BOOL *stop)
     {
         BOOL isEmoji = NO;

         if (singleEmoji && !NSEqualRanges(stringRange, substringRange))
         {
             // The string contains several characters. Go out
             result = NO;
             *stop = YES;
             return;
         }

         const unichar hs = [substring characterAtIndex:0];
         // Surrogate pair
         if (0xd800 <= hs &&
             hs <= 0xdbff)
         {
             if (substring.length > 1)
             {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc &&
                     uc <= 0x1f9c0)
                 {
                     isEmoji = YES;
                 }
             }
         }
         else if (substring.length > 1)
         {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3 ||
                 ls == 0xfe0f ||
                 ls == 0xd83c)
             {
                 isEmoji = YES;
             }
         }
         else
         {
             // Non surrogate
             if (0x2100 <= hs &&
                 hs <= 0x27ff)
             {
                 isEmoji = YES;
             }
             else if (0x2B05 <= hs &&
                      hs <= 0x2b07)
             {
                 isEmoji = YES;
             }
             else if (0x2934 <= hs &&
                      hs <= 0x2935)
             {
                 isEmoji = YES;
             }
             else if (0x3297 <= hs &&
                      hs <= 0x3299)
             {
                 isEmoji = YES;
             }
             else if (hs == 0xa9 ||
                      hs == 0xae ||
                      hs == 0x303d ||
                      hs == 0x3030 ||
                      hs == 0x2b55 ||
                      hs == 0x2b1c ||
                      hs == 0x2b1b ||
                      hs == 0x2b50)
             {
                 isEmoji = YES;
             }
         }

         if (!isEmoji)
         {
             result = NO;
             *stop = YES;
         }
     }];

    return result;
}

#pragma mark - Time interval

+ (NSString*)formatSecondsInterval:(CGFloat)secondsInterval
{
    NSMutableString* formattedString = [[NSMutableString alloc] init];
    
    if (secondsInterval < 1)
    {
        [formattedString appendFormat:@"< 1%@", [NSBundle mxk_localizedStringForKey:@"format_time_s"]];;
    }
    else if (secondsInterval < 60)
    {
        [formattedString appendFormat:@"%d%@", (int)secondsInterval, [NSBundle mxk_localizedStringForKey:@"format_time_s"]];
    }
    else if (secondsInterval < 3600)
    {
        [formattedString appendFormat:@"%d%@ %2d%@", (int)(secondsInterval/60), [NSBundle mxk_localizedStringForKey:@"format_time_m"],
         ((int)secondsInterval) % 60, [NSBundle mxk_localizedStringForKey:@"format_time_s"]];
    }
    else if (secondsInterval >= 3600)
    {
        [formattedString appendFormat:@"%d%@ %d%@ %d%@", (int)(secondsInterval / 3600), [NSBundle mxk_localizedStringForKey:@"format_time_h"],
         ((int)(secondsInterval) % 3600) / 60, [NSBundle mxk_localizedStringForKey:@"format_time_m"],
         (int)(secondsInterval) % 60, [NSBundle mxk_localizedStringForKey:@"format_time_s"]];
    }
    [formattedString appendString:@" left"];
    
    return formattedString;
}

+ (NSString *)formatSecondsIntervalFloored:(CGFloat)secondsInterval
{
    NSString* formattedString;

    if (secondsInterval < 0)
    {
        formattedString = [NSString stringWithFormat:@"0%@", [NSBundle mxk_localizedStringForKey:@"format_time_s"]];
    }
    else
    {
        NSUInteger seconds = secondsInterval;
        if (seconds < 60)
        {
            formattedString = [NSString stringWithFormat:@"%tu%@", seconds, [NSBundle mxk_localizedStringForKey:@"format_time_s"]];
        }
        else if (secondsInterval < 3600)
        {
            formattedString = [NSString stringWithFormat:@"%tu%@", seconds / 60, [NSBundle mxk_localizedStringForKey:@"format_time_m"]];
        }
        else if (secondsInterval < 86400)
        {
            formattedString = [NSString stringWithFormat:@"%tu%@", seconds / 3600, [NSBundle mxk_localizedStringForKey:@"format_time_h"]];
        }
        else
        {
            formattedString = [NSString stringWithFormat:@"%tu%@", seconds / 86400, [NSBundle mxk_localizedStringForKey:@"format_time_d"]];
        }
    }

    return formattedString;
}

#pragma mark - Phone number

+ (NSString*)msisdnWithPhoneNumber:(NSString *)phoneNumber andCountryCode:(NSString *)countryCode
{
    NSString *msisdn = nil;
    NBPhoneNumber *phoneNb;
    
    if ([phoneNumber hasPrefix:@"+"] || [phoneNumber hasPrefix:@"00"])
    {
        phoneNb = [[NBPhoneNumberUtil sharedInstance] parse:phoneNumber defaultRegion:nil error:nil];
    }
    else
    {
        // Check whether the provided phone number is a valid msisdn.
        NSString *e164 = [NSString stringWithFormat:@"+%@", phoneNumber];
        phoneNb = [[NBPhoneNumberUtil sharedInstance] parse:e164 defaultRegion:nil error:nil];
        
        if (![[NBPhoneNumberUtil sharedInstance] isValidNumber:phoneNb])
        {
            // Consider the phone number as a national one, and use the country code.
            phoneNb = [[NBPhoneNumberUtil sharedInstance] parse:phoneNumber defaultRegion:countryCode error:nil];
        }
    }
    
    if ([[NBPhoneNumberUtil sharedInstance] isValidNumber:phoneNb])
    {
        NSString *e164 = [[NBPhoneNumberUtil sharedInstance] format:phoneNb numberFormat:NBEPhoneNumberFormatE164 error:nil];
        
        if ([e164 hasPrefix:@"+"])
        {
            msisdn = [e164 substringFromIndex:1];
        }
        else if ([e164 hasPrefix:@"00"])
        {
            msisdn = [e164 substringFromIndex:2];
        }
    }
    
    return msisdn;
}

#pragma mark - Hex color to UIColor conversion

+ (UIColor *)colorWithRGBValue:(NSUInteger)rgbValue
{
    return [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0];
}

+ (UIColor *)colorWithARGBValue:(NSUInteger)argbValue
{
    return [UIColor colorWithRed:((float)((argbValue & 0xFF0000) >> 16))/255.0 green:((float)((argbValue & 0xFF00) >> 8))/255.0 blue:((float)(argbValue & 0xFF))/255.0 alpha:((float)((argbValue & 0xFF000000) >> 24))/255.0];
}

+ (NSUInteger)rgbValueWithColor:(UIColor*)color
{
    CGFloat red, green, blue, alpha;
    
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    
    NSUInteger rgbValue = ((int)(red * 255) << 16) + ((int)(green * 255) << 8) + (blue * 255);
    
    return rgbValue;
}

+ (NSUInteger)argbValueWithColor:(UIColor*)color
{
    CGFloat red, green, blue, alpha;
    
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    
    NSUInteger argbValue = ((int)(alpha * 255) << 24) + ((int)(red * 255) << 16) + ((int)(green * 255) << 8) + (blue * 255);
    
    return argbValue;
}

#pragma mark - Image

+ (UIImage*)forceImageOrientationUp:(UIImage*)imageSrc
{
    if ((imageSrc.imageOrientation == UIImageOrientationUp) || (!imageSrc))
    {
        // Nothing to do
        return imageSrc;
    }
    
    // Draw the entire image in a graphics context, respecting the image’s orientation setting
    UIGraphicsBeginImageContext(imageSrc.size);
    [imageSrc drawAtPoint:CGPointMake(0, 0)];
    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return retImage;
}

+ (MXKImageCompressionSizes)availableCompressionSizesForImage:(UIImage*)image originalFileSize:(NSUInteger)originalFileSize
{
    MXKImageCompressionSizes compressionSizes;
    memset(&compressionSizes, 0, sizeof(MXKImageCompressionSizes));
    
    // Store the original
    compressionSizes.original.imageSize = image.size;
    compressionSizes.original.fileSize = originalFileSize ? originalFileSize : UIImageJPEGRepresentation(image, 0.9).length;
    
    NSLog(@"[MXKRoomInputToolbarView] availableCompressionSizesForImage: %f %f - File size: %tu", compressionSizes.original.imageSize.width, compressionSizes.original.imageSize.height, compressionSizes.original.fileSize);
    
    compressionSizes.actualLargeSize = MXKTOOLS_LARGE_IMAGE_SIZE;
    
    // Compute the file size for each compression level
    CGFloat maxSize = MAX(compressionSizes.original.imageSize.width, compressionSizes.original.imageSize.height);
    if (maxSize >= MXKTOOLS_SMALL_IMAGE_SIZE)
    {
        compressionSizes.small.imageSize = [MXKTools resizeImageSize:compressionSizes.original.imageSize toFitInSize:CGSizeMake(MXKTOOLS_SMALL_IMAGE_SIZE, MXKTOOLS_SMALL_IMAGE_SIZE) canExpand:NO];
        
        compressionSizes.small.fileSize = (NSUInteger)[MXTools roundFileSize:(long long)(compressionSizes.small.imageSize.width * compressionSizes.small.imageSize.height * 0.20)];
        
        if (maxSize >= MXKTOOLS_MEDIUM_IMAGE_SIZE)
        {
            compressionSizes.medium.imageSize = [MXKTools resizeImageSize:compressionSizes.original.imageSize toFitInSize:CGSizeMake(MXKTOOLS_MEDIUM_IMAGE_SIZE, MXKTOOLS_MEDIUM_IMAGE_SIZE) canExpand:NO];
            
            compressionSizes.medium.fileSize = (NSUInteger)[MXTools roundFileSize:(long long)(compressionSizes.medium.imageSize.width * compressionSizes.medium.imageSize.height * 0.20)];
            
            if (maxSize >= MXKTOOLS_LARGE_IMAGE_SIZE)
            {
                // In case of panorama the large resolution (1024 x ...) is not relevant. We prefer consider the third of the panarama width.
                compressionSizes.actualLargeSize = maxSize / 3;
                if (compressionSizes.actualLargeSize < MXKTOOLS_LARGE_IMAGE_SIZE)
                {
                    compressionSizes.actualLargeSize = MXKTOOLS_LARGE_IMAGE_SIZE;
                }
                else
                {
                    // Keep a multiple of predefined large size
                    compressionSizes.actualLargeSize = floor(compressionSizes.actualLargeSize / MXKTOOLS_LARGE_IMAGE_SIZE) * MXKTOOLS_LARGE_IMAGE_SIZE;
                }
                
                compressionSizes.large.imageSize = [MXKTools resizeImageSize:compressionSizes.original.imageSize toFitInSize:CGSizeMake(compressionSizes.actualLargeSize, compressionSizes.actualLargeSize) canExpand:NO];
                
                compressionSizes.large.fileSize = (NSUInteger)[MXTools roundFileSize:(long long)(compressionSizes.large.imageSize.width * compressionSizes.large.imageSize.height * 0.20)];
            }
            else
            {
                NSLog(@"    - too small to fit in %d", MXKTOOLS_LARGE_IMAGE_SIZE);
            }
        }
        else
        {
            NSLog(@"    - too small to fit in %d", MXKTOOLS_MEDIUM_IMAGE_SIZE);
        }
    }
    else
    {
        NSLog(@"    - too small to fit in %d", MXKTOOLS_SMALL_IMAGE_SIZE);
    }
    
    return compressionSizes;
}


+ (CGSize)resizeImageSize:(CGSize)originalSize toFitInSize:(CGSize)maxSize canExpand:(BOOL)canExpand
{
    if ((originalSize.width == 0) || (originalSize.height == 0))
    {
        return CGSizeZero;
    }
    
    CGSize resized = originalSize;
    
    if ((maxSize.width > 0) && (maxSize.height > 0) && (canExpand || ((originalSize.width > maxSize.width) || (originalSize.height > maxSize.height))))
    {
        CGFloat ratioX = maxSize.width  / originalSize.width;
        CGFloat ratioY = maxSize.height / originalSize.height;
        
        CGFloat scale = MIN(ratioX, ratioY);
        resized.width  *= scale;
        resized.height *= scale;
        
        // padding
        resized.width  = floorf(resized.width  / 2) * 2;
        resized.height = floorf(resized.height / 2) * 2;
    }
    
    return resized;
}

+ (CGSize)resizeImageSize:(CGSize)originalSize toFillWithSize:(CGSize)maxSize canExpand:(BOOL)canExpand
{
    CGSize resized = originalSize;
    
    if ((maxSize.width > 0) && (maxSize.height > 0) && (canExpand || ((originalSize.width > maxSize.width) && (originalSize.height > maxSize.height))))
    {
        CGFloat ratioX = maxSize.width  / originalSize.width;
        CGFloat ratioY = maxSize.height / originalSize.height;
        
        CGFloat scale = MAX(ratioX, ratioY);
        resized.width  *= scale;
        resized.height *= scale;
        
        // padding
        resized.width  = floorf(resized.width  / 2) * 2;
        resized.height = floorf(resized.height / 2) * 2;
    }
    
    return resized;
}

+ (UIImage *)reduceImage:(UIImage *)image toFitInSize:(CGSize)size
{
    UIImage *resizedImage = image;
    
    // Check whether resize is required
    if (size.width && size.height)
    {
        CGFloat width = image.size.width;
        CGFloat height = image.size.height;
        
        if (width > size.width)
        {
            height = (height * size.width) / width;
            height = floorf(height / 2) * 2;
            width = size.width;
        }
        if (height > size.height)
        {
            width = (width * size.height) / height;
            width = floorf(width / 2) * 2;
            height = size.height;
        }
        
        if (width != image.size.width || height != image.size.height)
        {
            // Create the thumbnail
            CGSize imageSize = CGSizeMake(width, height);
            UIGraphicsBeginImageContext(imageSize);
            
            //            // set to the top quality
            //            CGContextRef context = UIGraphicsGetCurrentContext();
            //            CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
            
            CGRect thumbnailRect = CGRectMake(0, 0, 0, 0);
            thumbnailRect.origin = CGPointMake(0.0,0.0);
            thumbnailRect.size.width  = imageSize.width;
            thumbnailRect.size.height = imageSize.height;
            
            [image drawInRect:thumbnailRect];
            resizedImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
    }
    
    return resizedImage;
}

+ (UIImage*)resizeImage:(UIImage *)image toSize:(CGSize)size
{
    UIImage *resizedImage = image;
    
    // Check whether resize is required
    if (size.width && size.height)
    {
        UIGraphicsBeginImageContext(size);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
        
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        resizedImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
    }
    
    return resizedImage;
}

+ (UIImage*)paintImage:(UIImage*)image withColor:(UIColor*)color
{
    UIImage *newImage;
    
    const CGFloat *colorComponents = CGColorGetComponents(color.CGColor);
    
    // Create a new image with the same size
    UIGraphicsBeginImageContextWithOptions(image.size, 0, 0);
    
    CGContextRef gc = UIGraphicsGetCurrentContext();
    
    CGRect rect = (CGRect){ .size = image.size};
    
    [image drawInRect:rect
            blendMode:kCGBlendModeNormal
                alpha:1];
    
    // Binarize the image: Transform all colors into the provided color but keep the alpha
    CGContextSetBlendMode(gc, kCGBlendModeSourceIn);
    CGContextSetRGBFillColor(gc, colorComponents[0], colorComponents[1], colorComponents[2], colorComponents[3]);
    CGContextFillRect(gc, rect);
    
    // Retrieve the result into an UIImage
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImageOrientation)imageOrientationForRotationAngleInDegree:(NSInteger)angle
{
    NSInteger modAngle = angle % 360;
    
    UIImageOrientation orientation = UIImageOrientationUp;
    if (45 <= modAngle && modAngle < 135)
    {
        return UIImageOrientationRight;
    }
    else if (135 <= modAngle && modAngle < 225)
    {
        return UIImageOrientationDown;
    }
    else if (225 <= modAngle && modAngle < 315)
    {
        return UIImageOrientationLeft;
    }
    
    return orientation;
}

static NSMutableDictionary* backgroundByImageNameDict;

+ (UIColor*)convertImageToPatternColor:(NSString*)resourceName backgroundColor:(UIColor*)backgroundColor patternSize:(CGSize)patternSize resourceSize:(CGSize)resourceSize
{
    if (!resourceName)
    {
        return backgroundColor;
    }
    
    if (!backgroundByImageNameDict)
    {
        backgroundByImageNameDict = [[NSMutableDictionary alloc] init];
    }
    
    NSString* key = [NSString stringWithFormat:@"%@ %f %f", resourceName, patternSize.width, resourceSize.width];
    
    UIColor* bgColor = [backgroundByImageNameDict objectForKey:key];
    
    if (!bgColor)
    {
        UIImageView* backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, patternSize.width, patternSize.height)];
        backgroundView.backgroundColor = backgroundColor;
        
        CGFloat offsetX = (patternSize.width - resourceSize.width) / 2.0f;
        CGFloat offsetY = (patternSize.height - resourceSize.height) / 2.0f;
        
        UIImageView* resourceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(offsetX, offsetY, resourceSize.width, resourceSize.height)];
        resourceImageView.backgroundColor = [UIColor clearColor];
        UIImage *resImage = [UIImage imageNamed:resourceName];
        if (CGSizeEqualToSize(resImage.size, resourceSize))
        {
            resourceImageView.image = resImage;
        }
        else
        {
            resourceImageView.image = [MXKTools resizeImage:resImage toSize:resourceSize];
        }
        
        
        [backgroundView addSubview:resourceImageView];
        
        // Create a "canvas" (image context) to draw in.
        UIGraphicsBeginImageContextWithOptions(backgroundView.frame.size, NO, 0);
        
        // set to the top quality
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
        [[backgroundView layer] renderInContext: UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        
        bgColor = [[UIColor alloc] initWithPatternImage:image];
        [backgroundByImageNameDict setObject:bgColor forKey:key];
    }
    
    return bgColor;
}

#pragma mark - App permissions

+ (void)checkAccessForMediaType:(NSString *)mediaType
            manualChangeMessage:(NSString *)manualChangeMessage
      showPopUpInViewController:(UIViewController *)viewController
              completionHandler:(void (^)(BOOL))handler
{
    [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {

        dispatch_async(dispatch_get_main_queue(), ^{

            if (granted)
            {
                handler(YES);
            }
            else
            {
                // Access not granted to mediaType
                // Display manualChangeMessage
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:manualChangeMessage preferredStyle:UIAlertControllerStyleAlert];

                // On iOS >= 8, add a shortcut to the app settings (This requires the shared application instance)
                UIApplication *sharedApplication = [UIApplication performSelector:@selector(sharedApplication)];
                if (sharedApplication && UIApplicationOpenSettingsURLString)
                {
                    [alert addAction:[UIAlertAction actionWithTitle:[NSBundle mxk_localizedStringForKey:@"settings"]
                                                                     style:UIAlertActionStyleDefault
                                                                   handler:^(UIAlertAction * action) {
                                                                       
                                                                       NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                                       [sharedApplication performSelector:@selector(openURL:) withObject:url];
                                                                       
                                                                       // Note: it does not worth to check if the user changes the permission
                                                                       // because iOS restarts the app in case of change of app privacy settings
                                                                       handler(NO);
                                                                       
                                                                   }]];
                }
                
                [alert addAction:[UIAlertAction actionWithTitle:[NSBundle mxk_localizedStringForKey:@"ok"]
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * action) {
                                                            
                                                            handler(NO);
                                                            
                                                        }]];
                
                [viewController presentViewController:alert animated:YES completion:nil];
            }
            
        });
    }];
}

+ (void)checkAccessForCall:(BOOL)isVideoCall
manualChangeMessageForAudio:(NSString*)manualChangeMessageForAudio
manualChangeMessageForVideo:(NSString*)manualChangeMessageForVideo
 showPopUpInViewController:(UIViewController*)viewController
         completionHandler:(void (^)(BOOL granted))handler
{
    // Check first microphone permission
    [MXKTools checkAccessForMediaType:AVMediaTypeAudio manualChangeMessage:manualChangeMessageForAudio showPopUpInViewController:viewController completionHandler:^(BOOL granted) {

        if (granted)
        {
            // Check camera permission in case of video call
            if (isVideoCall)
            {
                [MXKTools checkAccessForMediaType:AVMediaTypeVideo manualChangeMessage:manualChangeMessageForVideo showPopUpInViewController:viewController completionHandler:^(BOOL granted) {

                    handler(granted);
                }];
            }
            else
            {
                handler(YES);
            }
        }
        else
        {
            handler(NO);
        }
    }];
}

+ (void)checkAccessForContacts:(NSString *)manualChangeMessage
     showPopUpInViewController:(UIViewController *)viewController
             completionHandler:(void (^)(BOOL granted))handler
{
    // Check if the application is allowed to list the contacts
    ABAuthorizationStatus cbStatus = ABAddressBookGetAuthorizationStatus();
    if (cbStatus == kABAuthorizationStatusAuthorized)
    {
        handler(YES);
    }
    else if (cbStatus == kABAuthorizationStatusNotDetermined)
    {
        // Request address book access
        ABAddressBookRef ab = ABAddressBookCreateWithOptions(nil, nil);
        if (ab)
        {
            ABAddressBookRequestAccessWithCompletion(ab, ^(bool granted, CFErrorRef error) {
                dispatch_async(dispatch_get_main_queue(), ^{

                    handler(granted);

                });
            });

            CFRelease(ab);
        }
        else
        {
            // No phonebook
            handler(YES);
        }
    }
    else if (cbStatus == kABAuthorizationStatusDenied && viewController && manualChangeMessage)
    {
        // Access not granted to the local contacts
        // Display manualChangeMessage
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:manualChangeMessage preferredStyle:UIAlertControllerStyleAlert];

        // On iOS >= 8, add a shortcut to the app settings (This requires the shared application instance)
        UIApplication *sharedApplication = [UIApplication performSelector:@selector(sharedApplication)];
        if (sharedApplication && UIApplicationOpenSettingsURLString)
        {
            [alert addAction:[UIAlertAction actionWithTitle:[NSBundle mxk_localizedStringForKey:@"settings"]
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        
                                                        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                        [sharedApplication performSelector:@selector(openURL:) withObject:url];
                                                        
                                                        // Note: it does not worth to check if the user changes the permission
                                                        // because iOS restarts the app in case of change of app privacy settings
                                                        handler(NO);
                                                        
                                                    }]];
        }
        [alert addAction:[UIAlertAction actionWithTitle:[NSBundle mxk_localizedStringForKey:@"ok"]
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * action) {
                                                    
                                                    handler(NO);
                                                    
                                                }]];
        
        [viewController presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        handler(NO);
    }
}

@end
