//
//  User.h
//  Product
//
//  Created by Stephen Meriwether on 10/4/14.
//  Copyright (c) 2014 CalHacksProductivity. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalGitGoodUser : NSObject

// Singleton class. MUST use + sharedInstance
+ (LocalGitGoodUser *)sharedInstance;

// sets the github username & password
- (void)setGithubPassword:(NSString *)githubPassword;
- (void)setGithubUsername:(NSString *)githubUsername;
- (void)setParseID:(NSString *)parseID;

// get the github username & password
- (NSString *)username;
- (NSString *)password;
- (NSString *)parseObjectID;

@end
