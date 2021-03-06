//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#include <ifaddrs.h>
#import "FLAnimatedImageView.h"
#import "FLAnimatedImage.h"
#import "Reachability.h"
#import "YSSupport.h"
#import "DSBarChart.h"
#import "YSSupport.h"
#import "SingleLineTextField.h"
#import "BIZProgressViewHandler.h"
#import "BIZCircularProgressView.h"
#import "LNBRippleEffect.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ARCarMovement.h"
#import "UIImage+fixOrientation.h"


#pragma mark - LIST OF API NAMES WITH ENDPOINT
//*********************************************

#pragma mark **** API NAME FOR RIDER ******
#define     API_PHONENO_VALIDATION          @"numbervalidation"
#define     API_SIGNUP                      @"register"
#define     API_SOCIAL_SIGNUP               @"socialsignup"
#define     API_CHECK_SOCIAL_ID             @"socialsignup"
#define     API_LOGIN                       @"login"
#define     API_OTP                         @"otp"
#define     API_LANGUAGE                    @"language-update"
#define     API_UPDATE_PASSWORD             @"forgotpassword"
#define     API_CHANGE_DRIVER_STATUS        @"driver-accept-request"
#define     API_GET_RIDER_PROFILE           @"get-rider-profile"
#define     API_DRIVER_NOT_ACCEPT           @"request-cars"
#define     API_ARRIVE_NOW                  @"arive-now"
#define     API_BEGIN_TRIP                  @"begin-trip"
#define     API_END_TRIP                    @"end-trip"
#define     API_CANCEL_TRIP                 @"cancel-trip"
#define     API_CASH_COLLECT                @"cash-collected"
#define     API_CURRENCY_LIST               @"currency-list"
#define     API_CHANGE_CURRENCY             @"update-user-currency"
#define     API_UPDATE_DEVICE_TOKEN         @"update-device"
#define     API_WEEKLY_EARNINGS             @"earning-chart"
#define     API_GETTING_TRIP_INFO           @"driver-trips-history"
#define     API_RATING                      @"driver-rating"
#define     API_RIDER_FEEDBACK              @"rider-feedback"
#define     API_GIVE_RATING                 @"trip-rating"
#define     API_PAY_STATEMENT               @"pay-statement"
#define     API_SENDING_REQUEST_TO_CAR      @"sendrequesttocar"
#define     API_UPDATING_DRIVER_LOCATION    @"driver-update-location"
#define     API_CHECK_DRIVER_STATUS         @"driver-check-status"
#define     API_AFTER_PAYMENT               @"afterpayment"
#define     API_UPDATE_VEHICLE_INFO         @"vehicle-details"
#define     API_VIEW_PROFILE_INFO           @"get-driver-profile"
#define     API_UPLOAD_PROFILE_IMAGE        @"upload-profile-image"
#define     API_UPLOAD_MAP_IMAGE            @"map-upload"
#define     API_UPDATE_PROFILE_INFO         @"update-driver-profile"
#define     API_UPLOAD_DOCUMENT             @"document-upload"
#define     API_UPDATE_PAYPAL_EMAIL         @"add-payout"
#define     API_LOGOUT                      @"logout"


#pragma mark LIST OF RIDER METHODS
//*********************************
#define     METHOD_PHONENO_VALIDATION           @"numbervalidation"
#define     METHOD_SIGNUP                       @"register"
#define     METHOD_SOCIAL_SIGNUP                @"socialsignup"
#define     METHOD_CHECK_SOCIAL_ID              @"checksocialmediaid"
#define     METHOD_LOGIN                        @"login"
#define     METHOD_OTP                          @"otp"
#define     METHOD_LANGUAGE                     @"language-update"
#define     METHOD_UPDATE_PASSWORD              @"forgotpassword"
#define     METHOD_CHANGE_DRIVER_STATUS         @"driver-accept-request"
#define     METHOD_DRIVER_NOT_ACCEPT            @"request-cars"
#define     METHOD_GET_RIDER_PROFILE            @"get-rider-profile"
#define     METHOD_ARRIVE_NOW                   @"arive-now"
#define     METHOD_BEGIN_TRIP                   @"begin-trip"
#define     METHOD_END_TRIP                     @"end-trip"
#define     METHOD_CANCEL_TRIP                  @"cancel-trip"
#define     METHOD_CASH_COLLECT                 @"cash-collected"
#define     METHOD_CURRENCY_LIST                @"currency-list"
#define     METHOD_CHANGE_CURRENCY              @"update-user-currency"
#define     METHOD_UPDATE_DEVICE_TOKEN          @"update-device"
#define     METHOD_WEEKLY_EARNINGS              @"earning-chart"
#define     METHOD_RATING                       @"driver-rating"
#define     METHOD_RIDER_FEEDBACK               @"rider-feedback"
#define     METHOD_GIVE_RATING                  @"trip-rating"
#define     METHOD_PAY_STATEMENT                @"pay-statement"
#define     METHOD_SEARCH_NEARESTCARS           @"search-cars"
#define     METHOD_SENDING_REQUEST_TO_CAR       @"sendrequesttocar"
#define     METHOD_UPDATING_DRIVER_LOCATION     @"driver-update-location"
#define     METHOD_CHECK_DRIVER_STATUS          @"driver-check-status"
#define     METHOD_AFTER_PAYMENT                @"afterpayment"
#define     METHOD_UPDATE_VEHICLE_INFO          @"vehicle-details"
#define     METHOD_UPDATE_PAYPAL_EMAIL          @"add-payout"
#define     METHOD_VIEW_PROFILE_INFO            @"get-driver-profile"
#define     METHOD_UPLOAD_PROFILE_IMAGE         @"upload-profile-image"
#define     METHOD_UPLOAD_MAP_IMAGE             @"map-upload"
#define     METHOD_UPDATE_PROFILE_INFO          @"update-driver-profile"
#define     METHOD_UPLOAD_DOCUMENT              @"document-upload"
#define     METHOD_GETTING_TRIP_INFO            @"driver-trips-history"
#define     METHOD_LOGOUT                       @"logout"
#define     METHOD_GET_STRIPE_COUNTRIES          @"stripe-supported-country-list"
#define     METHOD_GET_PAYOUT_LIST          @"payout-details"
#define     METHOD_DELETE_PAYOUT            @"payout-delete"
#define     METHOD_PAYOUT_CHANGE           @"payout-changes"
#define     METHOD_MAKE_DEFAULT_PAYOUT      @"payout-makedefault"
#define     METHOD_ADD_STRIPE_PAYOUT        @"add-payout-preference"


#pragma mark LIST OF CONSTANTS
//****************************

#define           USER_ACCESS_TOKEN         @"access_token"
#define           CEO_FacebookAccessToken   @"FBAcessToken"
#define           USER_FULL_NAME            @"full_name"
#define           USER_FIRST_NAME           @"first_name"
#define           USER_LAST_NAME            @"last_name"
#define           USER_IMAGE_THUMB          @"user_image"
#define           USER_FB_ID                @"user_fbid"
#define           USER_ID                   @"user_id"
#define           USER_EMAIL_ID             @"user_email_id"
#define           USER_CAR_ID               @"user_email_id"
#define           USER_DIAL_CODE            @"dial_code"
#define           USER_COUNTRY_CODE         @"user_country_code"
#define           USER_DEVICE_TOKEN         @"device_token"
#define           USER_STATUS               @"driver-check-status"
#define           TRIP_STATUS               @"trip_status"
#define           CASH_PAYMENT              @"cash"
#define           USER_CAR_DETAILS          @"car_details"
#define           USER_CAR_TYPE             @"car_type"
#define           USER_CAR_IDS              @"car_ids"
#define           USER_ONLINE_STATUS        @"user_online_status"
#define           USER_PAYPAL_EMAIL_ID      @"paypal_email_id"
#define           LICENSE_BACK              @"licence_back"
#define           LICENSE_FRONT             @"licence_front"
#define           LICENSE_INSURANCE         @"licence_insurance"
#define           LICENSE_RC                @"licence_rc"
#define           LICENSE_PERMIT            @"licence_permit"
#define           USER_CURRENCY_ORG         @"user_currency_org"
#define           USER_CURRENCY_SYMBOL_ORG  @"user_currency_symbol_org"
#define           USER_CURRENT_TRIP_ID      @"user_current_trip_id"
#define           USER_PHONE_NUMBER         @"phonenumber"
#define           USER_START_DATE           @"user_start_date"
#define           USER_END_DATE             @"user_end_date"
#define           USER_LONGITUDE            @"user_longitude"
#define           USER_LATITUDE             @"user_latitude"
#define           USER_LOCATION             @"user_location"
#define           NEXT_ICON_NAME             @"I"
#define           PICKUP_COORDINATES        @"rider_pickup_coordinates"
#define           CURRENT_TRIP_ID           @"user_current_trip_id"
#define           DEVICE_LANGUAGE           @"device_default_language"
#define           TRIP_RIDER_THUMB_URL      @"trip_rider_thumb_url"
#define           TRIP_RIDER_NAME           @"trip_rider_name"
#define           TRIP_RIDER_RATING         @"trip_rider_rating"
#define           IS_COMPANY_DRIVER         @"is_company_driver"

//StoryBoardNames
#define  STORY_MAIN     @"Main"
#define  STORY_PAYMENT  @"Payment"
#define  STORY_TRIP     @"Trip"
#define  STORY_ACCOUNT  @"Account"



