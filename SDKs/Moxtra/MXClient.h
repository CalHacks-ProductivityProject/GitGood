//
//  MXClient.h
//  MoxtraSDK
//
// Created by KenYu on 6/16/14.
// Copyright (c) 2013 Moxtra, Inc. All rights reserved.
//
// Check detail information in Moxtra SDK API documents.
//

// The domain for error responses from API calls
extern NSString *const MXClientErrorDomain;

// The MXClient may also return other NSError objects from other domains, such as
// * NSURLError domain

//Error code
typedef NS_ENUM(NSInteger, MXClientErrorCode) {
    
    MXClientErrorUnknownStatusCode = -3000,
    
    MXClientErrorInvalidParameter = 100,
    MXClientErrorNetworkError = 101,
    
    MXClientErrorUserLoginFailed = 102,
    MXClientErrorUserLoginCancelled = 103,     //The login operation failed because the user dismissed the dialog without logging in.
    MXClientErrorUserAccountAlreadyExist = 104,
    MXClientErrorUserAccountSetupFailed = 105,
    MXClientErrorInvalidUniqueID = 106,
    MXClientErrorInvalidAccessToken = 107,
    
    //Chat
    MXClientErrorChatStartFailed = 500,
    MXClientErrorInvalidBinderID = 501,
    MXClientErrorInviteMembersFailed = 502,
};


#pragma mark -
@protocol MXClientChatDelegate <NSObject>
@optional

/**
 * Called when the user invite attendees via pressing invite button in meet. The default values are both YES.
 */
- (BOOL)supportInviteContactsBySMS;
- (BOOL)supportInviteContactsByEmail;

/**
 * Called when the user invite attendees via pressing invite button in meet. Return the customized subject/body.
 * There will be default subject/body if return value is null.
 */
- (NSString *)bodyOfSMSContentWithMeetLink:(NSString*)meetLink;
- (NSString *)subjectOfEmailContent;
- (NSString *)HTMLBodyOfEmailContentWithMeetLink:(NSString*)meetLink;

/**
 * Called when user pressed add more button.
 */
- (void)chatAddFilesAction;

@end


#pragma mark -
/**
 * There are two user identity types and use for different cases.
 * User case one (kUserIdentityTypeIdentityUniqueID): you do not have a Moxtra account, and you just need to provide a unique id before use Moxtra client functions.
 * User case two (kUserIdentityTypeEmail): you do have a Moxtra account, and when you start meet there will be a pop up dialog to let you login if you never logged. and when you join meet you need not to login even if you never logged.
 *
 */
typedef enum enumUserIdentityType {
    kUserIdentityTypeEmail = 0,
    kUserIdentityTypeIdentityUniqueID,
    kUserIdentityTypeSSOAccessToken
}eUserIdentityType;


@interface MXUserIdentity : NSObject
@property (nonatomic, assign) eUserIdentityType userIdentityType;
@property (nonatomic, copy) NSString *userIdentity;
@end


typedef enum navigationBarIconStyle {
    kNavigationBarIconBlue = 0,
    kNavigationBarIconBlack,
    kNavigationBarIconWhite,
} navigationBarIconStyle;

@interface customizedNavigationBarStyle : NSObject
@property (nonatomic, readwrite, strong) UIColor *backgroundColor; //iOS 7 support, for iOS6, should replace MXSDK_customized_navigatorbar_bg.png to customize.
@property (nonatomic, readwrite, assign) navigationBarIconStyle iconStyle;
@end


#pragma mark -
@protocol MXClient <NSObject>
@required

#pragma mark initialize user
/**
 * Setup user information. It need OAuth login with Moxtra Account.
 * The 3rd party should not call any other APIs except clientWithApplicationClientID before initializeUserAccount success block call back.
 *
 * @param userIdentity
 *            The user identity.
 * @param firstName
 *            Ignore this parameter when user's identity type is kUserIdentityTypeEmail.
 *            User's firstName.
 * @param lastName
 *            Ignore this parameter when user's identity type is kUserIdentityTypeEmail.
 *            User's lastName.
 * @param avatar
 *            Ignore this parameter when user's identity type is kUserIdentityTypeEmail.
 *            User's avatar image. If need we will resize it according to the image size.
 * @param devicePushNotificationToken
 *            The device push notification token if the 3rd paryt need support notification for Moxtra client.
 * @param success
 *            Callback interface for notifying the calling application when
 *            setup user successed.
 * @param failure
 *            Callback interface for notifying the calling application when
 *            setup user failed.
 */
- (void)initializeUserAccount:(MXUserIdentity*)userIdentity
                        firstName:(NSString*)firstName
                         lastName:(NSString*)lastName
                           avatar:(UIImage*)avatar
      devicePushNotificationToken:(NSData*)deviceToken
                          success:(void(^)())success
                          failure:(void(^)(NSError *error))failure;


@optional

#pragma mark update user's profile
/**
 * Ignore this API when user's identity type is kUserIdentityTypeEmail that set in the initializeUserAccount.
 * If user need update their profile, you can call this API to update them.
 *
 * @param firstName
 *            User's firstName.
 * @param lastName
 *            User's lastName.
 * @param avatar
 *            User's avatar image. If need we will resize it according to the image size.
 * @param success
 *            Callback interface for notifying the calling application when
 *            update user's profile successed.
 * @param failure
 *            Callback interface for notifying the calling application when
 *            update user's profile failed.
 */
- (void)updateUserProfile:(NSString*)firstName
                 lastName:(NSString*)lastName
                   avatar:(UIImage*)avatar
                  success:(void(^)())success
                  failure:(void(^)(NSError *error))failure;


#pragma mark chat SDK
/**
 * Create a new chat and pop up the chat view automatically.
 *
 * @param popupRect
 *            The rect that you want to pop up the chat view.
 * @param success
 *            Callback interface for notifying the calling application when
 *            open chat successed.
 * @param failure
 *            Callback interface for notifying the calling application when
 *            open chat failed.
 */
- (void)createChat:(CGRect)popupRect
           success:(void(^)(NSString *binderID))success
           failure:(void(^)(NSError *error))failure;


/**
 * Open chat and pop up the chat view automatically.
 *
 * @param binderID
 *            The binder id that you need to open.
 * @param popupRect
 *            The rect that you want to pop up the chat view.
 * @param success
 *            Callback interface for notifying the calling application when
 *            open chat successed.
 * @param failure
 *            Callback interface for notifying the calling application when
 *            open chat failed.
 */
- (void)openChat:(NSString *)binderID
   withPopupRect:(CGRect)popupRect
         success:(void(^)())success
         failure:(void(^)(NSError *error))failure;


/**
 * Set chat delegate.
 *
 * @param delegate
 *            Callback interface for notifying the calling application during
 *            the chat.
 */
- (void)setDelegate:(id<MXClientChatDelegate>)delegate;


/**
 * 3rd party notification support
 *
 * Update device push notification token if the 3rd paryt need support notification for Moxtra client.
 * You should call this API in UIApplicationDelegate - (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
 */
- (void)updateRemoteNotificationsWithDeviceToken:(NSData*)deviceToken;

/**
 * Handle the remote notification if the 3rd paryt need support notification for Moxtra client.
 * Reture NO if Moxtra client could not handle the remote notification.
 * You should call this API in UIApplicationDelegate - (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
 */
- (BOOL)receiveRemoteNotificationWithUserInfo:(NSDictionary*)userInfo;

/**
 * Import files to current chat.
 * 3rd party can call this API in the delegate method chatAddFilesAction.
 */
- (void)importFilesWithFilePathArray:(NSArray*)filePathArray;

/**
 * Invite members with binder id.
 *
 * @param binderID
 *            The binder id that you want to invite members to join.
 * @param userIdentityArray
 *            The user identity array. The objects in the array are MXUserIdentity.
 * @param success
 *            Callback interface for notifying the calling application when
 *            invite members successed.
 * @param failure
 *            Callback interface for notifying the calling application when
 *            invite members failed.
 */
- (void)inviteMembers:(NSString *)binderID
    userIdentityArray:(NSArray*)userIdentityArray
              success:(void(^)())success
              failure:(void(^)(NSError *error))failure;


#pragma mark unlink
/**
 * Unlink Moxtra account.
 */
- (void)unlinkAccount:(void(^)(BOOL success))completion;


#pragma mark other APIs
// User login status
- (BOOL)isUserLoggedIn;

// User last name
- (NSString*)getUserLastName;

// User first name
- (NSString*)getUserFirstName;

// Customize navigation bar
- (void)setCustomizedNavigationBarStyle:(customizedNavigationBarStyle*)navigationBarStyle;

@end
