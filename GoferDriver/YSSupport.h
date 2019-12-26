/**
 * YSSupport.h
 *
 * @package GoferDriver
 * @subpackage Controller
 * @category Calendar
 * @author Trioangle Product Team
 * @version - Stable 1.0
 * @link http://trioangle.com
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface YSSupport : NSObject

+ (void)facebookInfoDisplayForRegistration;
////get screenShot of given View
//+ (UIImage *) getScreenShot : (UIView *) view;
//+ (UIImage *)imageRotatedByDegrees:(UIImage*)oldImage deg:(CGFloat)degrees;
////check network reachibility
+ (BOOL) isNetworkRechable;
+(NSString *)getDeviceToken;
+(BOOL)checkDeviceType;
+(float)angleFromCoordinate:(CLLocationCoordinate2D)first toCoordinate:(CLLocationCoordinate2D)second;

//// Getting array Pattern
//+ (NSMutableArray  *)getStacturedArrayForDisplayingUserFromArray:(NSArray *)array withNoOfImageBunch:(int)NoOfImageBunch
//;
//
//// Email Validation Checking ......
//+ (BOOL) validateEmail: (NSString *) candidate;
//
//+ (void) runSpinAnimationOnView:(UIView*)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat;
//
//+ (void) runDelaySpinAnimationOnView:(UIView*)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat;
//
//
//
//+ (UIColor *)colorFromHexString:(NSString *)hexString;
//+ (NSString *) getFormatedNumber : (NSString *) number;
//
//+(UIImage*)imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) i_width;
//
//+(NSString *)getCurrentDate;
//
//+(NSString *)getNewVideoUrl:(NSString *)mediaID;
//
//+(NSString*)replaceColonAndlastComa:(NSString*)string1;
//
//+(void)imageViewHide:(UIView*)sview;
//+(void)showImage:(UIButton *)button;
//+(void)webView:(UIWebView*)view seturl:(NSURL*)url;
//
//+(CGFloat)getCommentTextHeight : (NSString *) commentText;
//+(CGFloat)getStringWidth : (NSString *) s;
//+(CGFloat)getCommentTextHeight : (NSString *) commentText startIngPoint : (CGFloat) startingCordinate;
//+(CGFloat)getCommentTextHeight : (NSString *) commentText font:(CGFloat)fontValue;
//
//+(NSString *)stringByReplacingEmoji:(NSString *)existingString  withDict : (NSDictionary *)emojiDict;
//+(NSDictionary *)reverseEmojiAliases;
//+(NSString *)convertToCommaSeparatedFromArray:(NSArray*)array;
//+ (NSDictionary*)dictionaryFromResponseData:(NSData*)responseData;
//+(void)resetDefaultsLogout:(BOOL)isAccountDelete;
//+(NSAttributedString *)getStringWithImageAttachment:(UIImage *)img attributedString :(NSAttributedString *)attributedVal;
//+(UIColor *)randomColor;
+ (NSString*)escapedValue:(NSString *)originalValue;
//+(NSString *)getVal:(NSString *)str;
//+(void)activityUpdateReadStatus:(NSInteger)activityType;
//+(NSString *)getScreenName;
@end
