//
//  User.m
//  Product
//
//  Created by Stephen Meriwether on 10/4/14.
//  Copyright (c) 2014 CalHacksProductivity. All rights reserved.
//

#import "LocalGitGoodUser.h"

@interface LocalGitGoodUser()

// Github Information
@property (nonatomic, copy) NSString *githubUsername;
@property (nonatomic, copy) NSString *githubPassword;

@end

@implementation LocalGitGoodUser

+ (LocalGitGoodUser *)sharedInstance
{
    static LocalGitGoodUser *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[LocalGitGoodUser alloc] init];
    });
    
    return sharedInstance;
}

- (void)setGithubPassword:(NSString *)githubPassword
{
    _githubPassword = githubPassword;
}

- (void)setGithubUsername:(NSString *)githubUsername
{
    _githubUsername = githubUsername;
}

- (NSString *)username
{
    return self.githubUsername;
}

- (NSString *)password
{
    return self.githubPassword;
}

@end
